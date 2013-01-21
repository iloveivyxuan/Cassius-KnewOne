class Making.Routers.Reviews extends Backbone.Router

  routes:
    '': 'index'
    'reviews/:id': 'show'

  initialize: (options) ->
    @collection = new Making.Collections.Reviews 
    @collection.url = options.root + "/reviews"

  index: ->
    view = new Making.Views.ReviewsIndex
      collection: @collection
    $('#reviews').html(view.el)

  show: (id) ->
