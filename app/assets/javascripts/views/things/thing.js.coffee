class Making.Views.Thing extends Backbone.View

  tagName: "li"
  template: JST['things/thing']

  render: =>
    $(@el).html(@template(@model.attributes))
    this
  
