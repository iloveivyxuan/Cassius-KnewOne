# Editor.
#
# Edit Mode: main, complemental.
#

do (exports = Making) ->

  exports.Views.Editor = Backbone.View.extend

    el: '.editor'

    initialize: (data) ->
      @mode     = data.mode
      @template = HandlebarsTemplates['editor/' + data.template]
      @$submit  = @$('.editor-submit')
      @$drop    = @$('.editor-drop')
      @$close   = @$('.editor-close')
      @$output  = @$('.editor-menu output')
      @$content = @$('.editor-content')

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
              url: '/draft'
            .done (data, status, xhr) ->
              @$content.html(@template(data))
              @initPlugin()
              @$el.show()
          return
        else
          @$content.html(@template({}))
          @initPlugin()
          @$el.show()
          return

    initPlugin: ->
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
