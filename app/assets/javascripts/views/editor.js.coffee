# Editor.
#
# Edit Mode: main, complemental.
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
      # @template = HandlebarsTemplates['editor/' + options.template]
      @draftId    = (exports.user + '+' + 'draft' + location.pathname + '+' + @el.id).replace(/\//g, '+')
      @url        = location.origin + '/drafts/' + @draftId
      @$help      = @$('.editor-help')
      @$submit    = @$('.editor-submit')
      @$drop      = @$('.editor-drop')
      @$close     = @$('.editor-close')
      @$output    = @$('.editor-menu output')
      @$content   = @$('.editor-content')
      @$fields    = @$content.find('[name]')
      @$bodyField = @$('[name$="[content]"]')

      @listenTo @model, 'change:status', @showStatus

      @render()

    render: ->
      if @mode is 'complemental'
        @$drop.addClass('hidden')
        @$submit.addClass('hidden')
      else
        # @TODO
        # has draft?
        if false
          # @TODO
          # loading
          $
            .ajax
              url: @url
            .done (data, status, xhr) ->
              @$content.html(@template(data))
              if !@editor
                @activatePlugin()
              @$el.show()
        else
          # @$content.html(@template({}))
          if !@editor
            @activatePlugin()
          @$el.show()
      @initHelp()
      @initWidget()
      return @

    # @TODO
    reset: ->
      console.log 'TODO: reset.'

    showStatus: ->
      @$output.text(@model.get('status'))

    activatePlugin: ->
      @$body = @$('.editor-content > .body')

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
          images: {}
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

    formatDraft: ->
      content = {}

      @$bodyField.val(@editor.serialize()['element-0'].value)

      _.each @$fields, (element, index, list) ->
        $field = $(element)
        content[$field.attr('name')] = $field.prop('value')
      , @

      @model.get('draft').content = JSON.stringify(content)

      return @model.get('draft')

    hide: ->
      @$el.hide()
      $docbody.removeClass('editor-open')

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
      @save true, @hide

    drop: ->
      if confirm '确定舍弃文档吗？'
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

    submit: (event) ->
      @model.updateStatus('submit')
      @$bodyField.val(@editor.serialize()['element-0'].value)
