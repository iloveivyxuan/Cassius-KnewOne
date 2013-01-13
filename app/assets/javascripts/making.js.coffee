window.Making =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  initialize: ->

  thingForm: ->
    $(document).ready ->
      view = new Making.Views.PhotosUpload
      view.render()
      $('form#new_thing').submit (e) ->
        _.each $('#photos .uploaded'), (el) =>
          $('<input>').attr(
            name: "thing[photo_ids][]"
            value: $(el).data('photo-id')
            type: "hidden"
          ).appendTo $(this)
            
$(document).ready ->
  Making.initialize()
