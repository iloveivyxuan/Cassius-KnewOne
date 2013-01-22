class Making.Views.Thing extends Backbone.View

  tagName: "li"
  template: HandlebarsTemplates['things/thing']

  render: =>
    $(@el).html(@template(@model.attributes))
    this
  
