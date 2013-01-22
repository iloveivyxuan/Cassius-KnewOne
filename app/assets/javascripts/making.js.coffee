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
    csrf_token = $('meta[name=csrf-token]').attr('content');
    csrf_param = $('meta[name=csrf-param]').attr('content');
    params = ""
    if csrf_param && csrf_token
      params = csrf_param + "=" + encodeURIComponent(csrf_token);
    $form.find('textarea').redactor
      imageUpload: "/review_photos?" + params
      lang: 'zh_cn'

$ ->
  Making.initialize()
