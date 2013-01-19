window.Making =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  initialize: ->

  ThingsNew: ->
    $ ->
      view = new Making.Views.ThingsNew
        el: "form.thing_form"

  Reviews: (root) ->
    $ ->
      new Making.Routers.Reviews(root: root)
      Backbone.history.start(root: root)

$ ->
  Making.initialize()
