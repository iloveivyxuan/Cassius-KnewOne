class Making.Views.Photo extends Backbone.View

  tagName: 'li'
  className: 'uploaded'
  template: HandlebarsTemplates['photos/photo']

  events:
    "click .destroy": "destroy"

  render: =>
    @$el.html @template(@model.attributes)
    this

  destroy: (e) =>
    e.preventDefault()

    @$el.fadeOut =>
      @.remove()
