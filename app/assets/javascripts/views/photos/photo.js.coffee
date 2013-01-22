class Making.Views.Photo extends Backbone.View

  tagName: 'li'
  className: 'uploaded'
  template: HandlebarsTemplates['photos/photo']

  events: 
    "click .destroy": "destroy"

  render: =>
    @$el.html JST['photos/photo']
      small_url: @model.get('small_url')
      url: @model.get('url')
      name: @model.get('name')
    this

  destroy: (e) =>
    @$el.fadeOut =>
      @remove()
    e.preventDefault()



