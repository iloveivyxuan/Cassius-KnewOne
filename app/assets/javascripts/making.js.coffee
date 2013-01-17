window.Making =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  initialize: ->

  ThingsNew: ->
    $(document).ready ->
      view = new Making.Views.ThingsNew
        el: "form.thing_form"

$(document).ready ->
  Making.initialize()
