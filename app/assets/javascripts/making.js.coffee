window.Making =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  initialize: ->

  ThingsIndex: ->
    $ ->
      collection = new Making.Collections.Things()
      view = new Making.Views.ThingsIndex(collection: collection)
      $('#things').html(view.el)

  ThingsNew: ->
    $ ->
      view = new Making.Views.ThingsNew
        el: "form.thing_form"

  Reviews: (root) ->
    $ ->
      new Making.Routers.Reviews(root: root)
      Backbone.history.start(root: root)

  ThingSummary: ->
    $ ->
      view = new Making.Views.ThingSummary
        el: "#thing_summary"
    
  Editor: ($form) ->
    $form.find('textarea').wysihtml5
      locale: "zh-CN"

$ ->
  Making.initialize()
