do (exports = Making) ->

  exports.Views.Drafts = Backbone.View.extend

    el: '.drafts'

    initialize: ->
      @drafts = new exports.Collections.Drafts()

      @listenTo @drafts, 'reset', @render

      @drafts.fetch({reset: true})

    render: ->
      _.each @drafts.models, (draft, index, list) ->
        draftView = new exports.Views.Draft({model: draft})
        @$el.append(draftView.render().el)
      , @
