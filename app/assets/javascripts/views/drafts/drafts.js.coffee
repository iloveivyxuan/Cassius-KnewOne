do (exports = Making) ->

  exports.Views.Drafts = Backbone.View.extend

    el: '.drafts'

    events:
      'click .destory': 'destory'

    initialize: ->
      @drafts = new exports.Collections.Drafts()

      @listenTo @drafts, 'sync', @render

      @drafts.fetch()

    render: ->
      @list = []
      _.each @drafts.models, (draft, index, list) ->
        draftView = new exports.Views.Draft({model: draft})
        @list.push(draftView.render().el)
      , @
      @$el.append(@list)

    destory: (event) ->
      event.preventDefault()
      $target = $(event.target)
      @drafts.findWhere({'id': $target.data('id')}).destroy()
