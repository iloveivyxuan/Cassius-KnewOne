do (exports = Making) ->

  exports.Views.Editor = Backbone.View.extend

    el: '.editor'

    initialize: (data)->
      @type     = data.type
      @template = HandlebarsTemplates['editor/' + @type]
      @render()

    render: ->
      # @TODO
      # has draft?
      if false
        # @TODO
        # loading
        $
          .ajax
            url: '/draft'
          .done (data, status, xhr) ->
            @$el.html(@template(data))
            @initPlugin()
            @$el.show()
        return
      else
        @$el.html(@template({}))
        @initPlugin()
        @$el.show()
        return

    initPlugin: ->
      @$body = @$('.editor-inner > .body')

      @editor = new MediumEditor @$body,
        buttons: ['header1', 'header2', 'bold', 'italic', 'quote', 'anchor',
                    'orderedlist', 'unorderedlist']
        buttonLabels: 'fontawesome'
        firstHeader: 'h2'
        secondHeader: 'h3'
        placeholder: '在这里记下你的想法～'
        targetBlank: true

      @$body.mediumInsert
        editor: @editor
        addons:
          images: {}
          embeds: {}
