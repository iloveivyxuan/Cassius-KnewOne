# Editor.
#
# Edit Mode:
#   standalone: Init from new page.
#   complemental: Init from current page.
#

do (exports = Making) ->

  exports.Views.Editor = Backbone.View.extend

    events:
      'change [name]'                : 'save'
      'input .editor-content > .body': 'save'
      'click .editor-close'          : 'close'
      'click .editor-drop'           : 'drop'
      'click .editor-save'           : 'send'
      'click .editor-submit'         : 'submit'

    initialize: (options) ->
      @mode       = options.mode
      @draftId    = exports.user +
                    '+draft+' +
                    encodeURIComponent(location.pathname) +
                    '+#' + (@el.id ? '')
      @url        = location.origin + '/drafts/' + @draftId
      @$help      = @$('.editor-help')
      @$submit    = @$('.editor-submit')
      @$drop      = @$('.editor-drop')
      @$close     = @$('.editor-close')
      @$output    = @$('.editor-menu output')
      @$content   = @$('.editor-content')
      @$body      = @$content.children('.body')
      @$fields    = @$content.find('[name]')
      @$bodyField = @$('[name$="[content]"]')

      @listenTo @model, 'change:status', @showStatus

      @render()

    render: ->
      switch @mode
        when 'standalone'
          that = @

          @model.updateStatus('load')
          @$close.addClass('hidden')

          $
            .ajax
              url: that.url
              type: 'get'
            .done (data, status, xhr) ->
              that.fillDraft(JSON.parse(data.content))
            .fail (xhr, status, error) ->
              if xhr.status is 404 and localStorage[that.draftId] isnt undefined
                that.fillDraft(JSON.parse(JSON.parse(localStorage[that.draftId]).content))
            .always ->
              that.model.updateStatus('edit')
              that.show()
              that.initWidget()
              that.initHelp()
        when 'complemental'
          # @TODO
          @$drop.addClass('hidden')
          @$submit.addClass('hidden')
      @

    # @TODO
    reset: ->
      console.log 'TODO: reset.'

    fillDraft: (draft) ->
      @setContent(draft)

    show: ->
      @getBody()
      @activatePlugin()
      @$el.show()

    hide: ->
      @$el.hide()
      $docbody.removeClass('editor-open')

    showStatus: ->
      @$output.text(@model.get('status'))

    activatePlugin: ->
      @editor = new MediumEditor @$body,
        buttons: ['header1', 'header2', 'bold', 'italic', 'quote', 'anchor',
                    'orderedlist', 'unorderedlist']
        buttonLabels: 'fontawesome'
        firstHeader: 'h2'
        secondHeader: 'h3'
        placeholder: '正文'
        targetBlank: true

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
      @$body.mediumInsert('disable')

    initHelp: ->
      self = @
      @$help
        .popover
          html: true
        .popover('show')

      setTimeout ->
        self.$help.popover('hide')
      , 3000

    initWidget: ->
      !@$rating && (@$rating = @$('.range-rating')).length && @$rating.rating()

    getBody: ->
      @$body.html(@$bodyField.val())

    setBody: ->
      @$bodyField.val(@editor.serialize()[@$body.attr('id')].value)

    getContent: ->
      content = {}

      @setBody()

      _.each @$fields, (element, index, list) ->
        $field = $(element)
        content[$field.attr('name')] = $field.prop('value')
      , @

      @model.get('draft').content = JSON.stringify(content)

      return @model.get('draft')

    setContent: (content) ->
      _.each @$fields, (element, index, list) ->
        $field = $(element)
        key    = $field.prop('name')
        $field.prop('value', content[key])
      , @

      @getBody()

    save: (persisten, callback) ->
      console.log 'save'
      @model.updateStatus('save')

      if persisten is true
        that  = @
        draft = @getContent()

        @model.updateStatus('save')

        $
          .ajax
            url: that.url
            type: 'put'
            data:
              draft: draft
          .done (data, status, xhr) ->
            localStorage.removeItem(that.draftId)
            that.model.updateStatus('edit')
            if (typeof callback) isnt undefined then callback()
      else
        localStorage[@draftId] = JSON.stringify(@getContent())
        @model.updateStatus('edit')

    close: ->
      callback = null

      switch @mode
        when 'complemental'
          callback = @hide

      @save true, callback

    drop: ->
      if confirm '确定舍弃文档吗？'
        that     = @
        callback = null

        switch @mode
          when 'standalone'
            callback = ->
              window.close()
          when 'complemental'
            callback = ->
              @hide()
              @reset()
              @deactivatePlugin()
              @$el.data('editor', null)

        @model.updateStatus('drop')

        $
          .ajax
            url: that.url
            type: 'delete'
          .always ->
            localStorage.removeItem(that.draftId)
            callback()

    submit: (event) ->
      @model.updateStatus('submit')
      @setBody()

    # @TODO
    send: ->
      @save(true)
