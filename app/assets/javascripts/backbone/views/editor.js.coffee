# Editor.
#
# Edit Mode:
#   standalone: Init from new page.
#   complemental: Init from current page.
#

do (exports = Making) ->

  exports.Views.Editor = Backbone.View.extend

    events:
      'change [name]'        : 'save'
      'input'                : 'autoSave'
      'click .editor-close'  : 'close'
      'click .editor-drop'   : 'drop'
      'click .editor-save'   : 'save'
      'click .editor-submit' : 'submit'

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

              document.execCommand('insertHTML', false, html);
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
        @editor = new MediumEditor @$body,
          buttons: ['anchor', 'bold', 'italic', 'strikethrough', 'header1', 'header2', 'quote']
          buttonLabels: 'fontawesome'
          firstHeader: 'h2'
          secondHeader: 'h3'
          placeholder: @placeholder
          anchorInputPlaceholder: '在这里插入链接'
          targetBlank: true
      else
        @editor.activate()

      @$body.mediumInsert
        editor: @editor
        addons:
          images:
            useDragAndDrop: false
            domain: $('#file').data('domain')
            templateFile: $('#file')
          embeds: {}

    deactivatePlugin: ->
      @editor.deactivate()
      # @TODO
      @$body.off('.mediumInsert')

    initHelp: ->
      that      = @
      key       = exports.user + '+hide-editor-help'
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
      Making.AtUser('#form-review-body')

    getBody: ->
      @$body.html(@$bodyField.val())

    setBody: (value = @editor.serialize()[@$body.attr('id')].value) ->
      @$bodyField.val(value)

    setContent: ->
      @setBody()

      _.each @$fields, (element, index, list) ->
        $field = $(element)
        @draft.set($field.attr('name'), $field.prop('value'))
      , @

    getContent: (content) ->
      _.each @$fields, (element, index, list) ->
        $field = $(element)
        key    = $field.prop('name')
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

    autoSave: (event) ->
      that = @
      @typingTime = new Date()

      setTimeout ->
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
              console.log 'drop callback'
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
          @model.updateStatus('submit')
          @setBody()

          if @beforeSubmit?
            result = @beforeSubmit(event)
            if result is false then return false

          $window
            .off 'beforeunload'

      return true

    beforeunload: ->
      if !@model.get('persisten')
        return '文档还未保存，确定要离开吗？'
