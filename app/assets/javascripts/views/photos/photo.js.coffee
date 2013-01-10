class Making.Views.Photo extends Backbone.View

  template: JST['photos/photo']
  tagName: 'li'

  initialize: ->

  render: =>
    $(@el).html @template(@model)
    this
  
