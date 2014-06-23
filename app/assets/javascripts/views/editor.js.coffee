# Editor.
#
# Edit Mode:
#   standalone: Init from new page.
#   complemental: Init from current page.
#

do (exports = Making) ->

  exports.Views.Editor = Backbone.View.extend

    events:
      'change [name]': 'save'
      'input .editor-content > .body': 'save'
      'click .editor-close': 'close'
      'click .editor-drop': 'drop'
      'click .editor-submit': 'submit'

    initialize: (options) ->
      @mode       = options.mode
      @draftId    = (exports.user + '+' + 'draft' + location.pathname + '+' + @el.id).replace(/\//g, '+')
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
      @model.updateStatus('edit')

      switch @mode
        when 'standalone'
          @$close.addClass('hidden')
          # @TODO
          # has draft?
          if false
            # @TODO
            @model.updateStatus('load')
            $
              .ajax
                url: @url
                type: 'get'
              .done (data, status, xhr) ->
                @model.updateStatus('edit')
                @show()
          else
            @show()
        when 'complemental'
          # @TODO
          @$drop.addClass('hidden')
          @$submit.addClass('hidden')

      @initHelp()
      @initWidget()
      @

    # @TODO
    reset: ->
      console.log 'TODO: reset.'

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
      @$bodyField.val(@editor.serialize()['element-0'].value)

    formatDraft: ->
      content = {}

      @setBody()

      _.each @$fields, (element, index, list) ->
        $field = $(element)
        content[$field.attr('name')] = $field.prop('value')
      , @

      @model.get('draft').content = JSON.stringify(content)

      return @model.get('draft')

    save: (persisten, callback) ->
      console.log 'save'
      if persisten is true
        draftId = @draftId
        draft   = @formatDraft()
        hide    = _.bind(@hide, @)

        @model.updateStatus('save')
        $
          .ajax
            url: @url
            type: 'put'
            data:
              draft: draft
          .done (data, status, xhr) ->
            localStorage.removeItem(draftId)
            hide()
      else
        localStorage[@draftId] = JSON.stringify(@formatDraft())

    read: ->
      $
        .ajax
          url: @url
          type: 'get'
        .done (data, status, xhr) ->

    close: ->
      callback = null

      switch @mode
        when 'standalone'
          callback = -> history.back()
        when 'complemental'
          callback = @hide

      @save true, callback

    drop: ->
      if confirm '确定舍弃文档吗？'
        $el              = @$el
        draftId          = @draftId
        hide             = _.bind(@hide, @)
        reset            = _.bind(@reset, @)
        deactivatePlugin = _.bind(@deactivatePlugin, @)

        @model.updateStatus('drop')
        # @TODO
        $
          .ajax
            url: @url
            type: 'delete'
          .done (data, status, xhr) ->
            localStorage.removeItem(draftId)
            hide()
            reset()
            deactivatePlugin()
            $el.data('editor', null)

    submit: (event) ->
      @model.updateStatus('submit')
      @setBody()
