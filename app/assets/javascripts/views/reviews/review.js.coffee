class Making.Views.Review extends Backbone.View

  tagName: 'li'
  template: JST['reviews/review']

  events:
    'click .detail': 'show'
    'click .destroy': 'destroy'

  initialize: ->
    @model.on
      change:  @render

  render: =>
    $(@el).html(@template(title: @model.get('title'), content: @model.get('content')))
    this

  show: ->
    Backbone.history.navigate("reviews/#{@model.get('id')}", true)

  destroy: (e) =>
    e.preventDefault()
    @model.destroy
      success: (model, response) =>
        @$el.fadeOut =>
          @remove()
