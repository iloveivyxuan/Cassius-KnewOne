class Making.Views.ThingsIndex extends Backbone.View

  tagName: "ul"

  template: HandlebarsTemplates['things/index']

  initialize: ->
    @collection.on
      reset: @render
    @collection.fetch()

  render: =>
    @collection.each @append
    this

  append: (thing) =>
    view = new Making.Views.Thing(model: thing)
    @$el.append(view.render().el)
