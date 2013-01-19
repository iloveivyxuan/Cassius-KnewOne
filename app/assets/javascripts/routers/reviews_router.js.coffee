class Making.Routers.Reviews extends Backbone.Router

  routes:
    '': 'index'
    'reviews/:id': 'show'

  initialize: (options) ->
    @collection = new Making.Collections.Reviews $('#reviews').data('reviews')
    @collection.url = options.root + "/reviews"

  index: ->
    view = new Making.Views.ReviewsIndex(collection: @collection)
    $('#reviews').html(view.render().el)

  show: (id) ->
