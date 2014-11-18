# Editor.
#
# Edit Mode:
#   standalone: Init from new page.
#   complemental: Init from current page.
#

do (exports = Making) ->

  exports.Views.Editor = Backbone.View.extend

    events:
      'input'                : 'autoSave'
      'click .editor-close'  : 'close'
      'click .editor-drop'   : 'drop'
      'click .editor-save'   : 'save'
      'click .editor-submit' : 'submit'
      'submit .editor-form'  : 'submit'

    initialize: (options) ->
      @mode        = options.mode
      @type        = options.type
      @$spinner    = $('.spinner-fullscreen')
      @$submit     = @$('.editor-submit')
      @$drop       = @$('.editor-drop')
      @$close      = @$('.editor-close')
      @$output     = @$('.editor-menu output')
      @$content    = @$('.editor-content')
      @$body       = @$content.children('.body')
      @$fields     = @$content.find('[name]').filter(":not(#{options.excludeField})")
      @placeholder = options.placeholder
      @$bodyField  = if options.bodyField? then $(options.bodyField) else
                      @$('[name$="[content]"]')
      @$help       = $('.editor-help')
      @$helpToggle = @$('.editor-help-toggle')
      @$imageField = $('#file')
      @$form       = $(@$bodyField[0].form)
      @draft       = new exports.Models.Draft
                      type: @type
                      id: exports.user + '+draft+' +
                            encodeURIComponent(location.pathname) +
                            '+#' + (@el.id ? '')
                      link: location.href
      @beforeSubmit = options.beforeSubmit
      @delay        = 1500
      @typingTime   = 0

      if @mode is 'complemental'
        @$origin = $(options.origin)
        @$toggle = $(options.toggle)

      @listenTo @model, 'change:status', @showStatus
      @listenTo @$bodyField, 'change', @autoSave

      @render()

    render: ->
      switch @mode

        when 'standalone'
          that = @

          @$drop.addClass('hidden')

          $
            .ajax
              url: @draft.url()
              type: 'get'
            .done (data, status, xhr) ->
              that.getContent(data)
            .always ->
              that.show()
              that.initWidget()
              that.appendDraftId()
              that.initHelp()

        when 'complemental'
          that = @

          @$drop.addClass('hidden')
          @$submit.addClass('hidden')

          $
            .ajax
              url: @draft.url()
              type: 'get'
            .done (data, status, xhr) ->
              that.setBody(data[that.type + '[content]'])
            .always () ->
              that.$origin.html(that.$bodyField.val())
              that.appendDraftId()

          @$origin
            .on 'keydown', _.bind (event) ->
              if event.keyCode is 13
                document.execCommand('formatblock', false, '<p>')

              if @$origin.html().length is 0
                @$origin.empty()
                document.execCommand('formatblock', false, '<p>')
            , @

            .on 'paste', _.bind (event) ->
              event.preventDefault()

              clipboardData = event.originalEvent.clipboardData || window.clipboardData
              paragraphs    = clipboardData.getData('text').split(/[\r\n]/g)
              html          = ''

              _.each paragraphs, (paragraph, index, list) ->
                if paragraph isnt ''
                  if (navigator.userAgent.match(/firefox/i) && index is 0)
                    html += exports.htmlEntities(paragraph)
                  else
                    html += '<p>' + exports.htmlEntities(paragraph) + '</p>'

              document.execCommand('insertHTML', false, html)
            , @

            .on 'blur', _.bind (event) ->
              @setBody(@$origin.html())
            , @

          @$toggle.on 'click', _.bind (event) ->
            event.preventDefault()
            @getBody()
            @show()
            @initHelp()
            $docbody.addClass('editor-open')
          , @

          @$form.on 'submit', _.bind(@submit, @)

      return this

    # @TODO
    reset: ->
      console.log 'TODO: reset.'

    show: ->
      that = @
      @getBody()
      @activatePlugin()
      @$el.show()
      @$spinner.addClass('hidden')

      $window
        .on 'beforeunload', (_.bind @beforeunload, @)

    hide: ->
      @$el.hide()
      $docbody.removeClass('editor-open')
      @deactivatePlugin()
      $window
        .off 'beforeunload'

    showStatus: ->
      @$output.text(@model.get('status'))

    activatePlugin: ->
      if !@editor
        that = @

        @editor = new MediumEditor @$body,
          buttons: ['anchor', 'bold', 'italic', 'strikethrough', 'quote']
          buttonLabels: 'fontawesome'
          placeholder: @placeholder
          anchorInputPlaceholder: '在这里插入链接'
          targetBlank: true

        if typeof MutationObserver in ['function', 'object']
          @observer = new MutationObserver (mutations) ->
            mutations.forEach (mutation) ->
              addedNodes = mutation.addedNodes
              if addedNodes.length
                for node in addedNodes
                  do (node) ->
                    if node.nodeName is 'SPAN'
                      selection = window.getSelection()
                      range     = selection.getRangeAt(0)
                      $(node).contents().unwrap()
                      selection.removeAllRanges()
                      selection.addRange(range)
          @observer.observe @$body[0], {childList: true, subtree: true}

        @$body.minsert()

        @$insertImageButton = @$('.minsert [data-action="insert-image"]')
          .on 'click', ->
            that.$imageField.clone(true).click()

        @$imageField
          .removeAttr('id')
          .attr('multiple', true)
          .attr('accept', 'image/*')
          .fileupload
            dataType: 'json'
            dropZone: null
            formData: ->
              return [{
                name: 'policy'
                value: that.$imageField.attr('data-policy')
              }, {
                name: 'signature'
                value: that.$imageField.attr('data-signature')
              }]
            beforeSend: (jqXHR, settings) ->
              # @TODO
              id = jqXHR.requestid = new Date().getTime()
              that.$body.trigger('loading.minsert', id)
            done: (event, data) ->
              url = that.$imageField.data('domain') + data.jqXHR.responseJSON.url + '!review'
              id  = data.jqXHR.requestid
              that.$body.trigger('done:image.minsert', {url, id})
            fail: (event, data) ->
              message = data.jqXHR.responseJSON.message.trim()
              switch message
                when 'Authorize has expired'
                  message = 'Authorize has expired. 请保存草稿后刷新一下页面，然后重试下。'
              that.$body.trigger('fail:image.minsert', message)
            always: (event, data) ->
              id = data.jqXHR.requestid
              that.$body.trigger('loaded.minsert', id)

      else
        @editor.activate()
        @observer.observe() if typeof MutationObserver is 'function'

    deactivatePlugin: ->
      @observer.disconnect() if typeof MutationObserver is 'function'
      @editor.deactivate()

    initHelp: ->
      that      = @
      key       = exports.user + '+hide-editor-help+v1'
      isHide    = localStorage[key]
      $checkbox = $('#show-editor-help')

      @$helpToggle.one 'click', ->
        that.$help.find('img[data-src]').each ->
          src = @getAttribute('data-src')
          @setAttribute('src', src)

      if isHide is 'true'
        $checkbox.attr('checked', true)
      else
        $checkbox.removeAttr('checked')

      if $checkbox.prop('checked') isnt true
        @$helpToggle.trigger('click')

      $checkbox.on 'change', ->
        localStorage[key] = $(@).prop('checked')

    initWidget: ->
      !@$rating && (@$rating = @$('.range-rating')).length && @$rating.rating()
      exports.AtUser('#form-review-body')
      $('.knewone-embed:empty').length && exports.loadEmbed()

    getBody: ->
      @$body.html(@$bodyField.val())

    setBody: (value = @editor.serialize()[@$body.attr('id')].value) ->
      @$bodyField.val(value)

    setContent: ->
      @setBody()

      _.each @$fields, (element, index, list) ->
        $field = $(element)
        switch $field.attr('type')
          when 'checkbox', 'radio'
            @draft.set($field.attr('name') + $field.val(), $field.prop('checked'))
          else
            @draft.set($field.attr('name'), $field.prop('value'))
      , @

    getContent: (content) ->
      _.each @$fields, (element, index, list) ->
        $field = $(element)
        key    = $field.prop('name')
        switch $field.attr('type')
          when 'checkbox', 'radio'
            $field.prop('checked', content[key + $field.val()])
          else
            $field.prop('value', content[key])
      , @

      @getBody()

    appendDraftId: ->
      @$form.append($('<input>', {
        type: 'hidden'
        name: 'draft[key]'
        value: @draft.get('id')
      }))

    save: (callback) ->
      switch @mode
        when 'standalone'
          @setContent()
        when 'complemental'
          @setBody()
          @draft.set(@$bodyField.attr('name'), @$bodyField.prop('value'))

      that  = @
      draft = @draft.toJSON()

      @model.updateStatus('save')
      @draft.save null,
        success: (model, response, options) ->
          that.model.updateStatus('edit')
          that.model.set('persisten', true)
          if (typeof callback is 'function') then callback()
        error: (model, response, options)->
          if response.responseJSON.error?
            that.model.updateStatus('error')
            alert('杯具，出错了，请把内容保存到电脑后刷新页面再试试。给您带来的不便，我们深表歉意！')

    autoSave: (event) ->
      that = @
      @typingTime = new Date()

      @model.set('persisten', false)
      @timeout = setTimeout ->
        if (new Date() - that.typingTime) > that.delay
          that.save()
      , @delay

    close: ->
      that = @

      @save ->
        switch that.mode
          when 'standalone'
            window.close()
          when 'complemental'
            that.hide()
            that.$origin
              .empty()
              .html(that.$bodyField.val())

    drop: ->
      if confirm '确定删除草稿吗？'
        callback = null

        switch @mode
          when 'standalone'
            callback = ->
              window.close()
          when 'complemental'
            callback = ->
              @hide()
              @reset()
              @$el.data('editor', null)

        @model.updateStatus('drop')
        $window
          .off 'beforeunload'
        @draft.destroy
          success: callback

    submit: (event) ->
      switch @mode
        when 'standalone'
          clearTimeout(@timeout)
          body = $('<div>')
                  .append(@editor.serialize()[@$body.attr('id')].value)
                  .find('.knewone-embed')
                    .empty()
                    .removeAttr('contenteditable')
                  .end()[0].innerHTML
          @setBody(body)

          if @beforeSubmit?
            result = @beforeSubmit(event)
            if result is false then return false

          @model.updateStatus('submit')

          $window
            .off 'beforeunload'

      return true

    beforeunload: ->
      if @model.get('persisten') is false
        return '文档还未保存，确定要离开吗？'
