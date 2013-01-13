class Making.Views.Photo extends Backbone.View

  tagName: 'li'
  className: 'uploaded'
  template: JST['photos/photo']

  events: 
    "click .destroy": "destroy"

  initialize: =>
  	@listenTo @model, 'destroy', @remove
  
  render: =>
    @$el.html JST['photos/photo']
      url: @model.get('url')
      name: @model.get('name')
    this

  destroy: (e) =>
    @model.destroy()
    e.preventDefault()



