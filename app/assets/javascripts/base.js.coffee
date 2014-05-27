# Base

do (root = this) ->
  root.Making =
    Models     : {}
    # TODO
    View       : {}
    Views      : {}
    Collections: {}
    Routers    : {}
    Events     : _.clone(Backbone.Events)

  root.$document = $(document)
  root.$window   = $(window)
  root.$html     = $('html')
  root.$docbody  = $('body')

  root.EventBus =

    trigger: (event, data) ->
      e = $.Event(event)
      e.param = data
      $document.trigger(e)

    on: (event, callback) ->
      $document.on(event, callback)

    off: (event) ->
      $document.off(event)

  return
