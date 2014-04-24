class Making.Views.FeelingNew extends Backbone.View

  events:
    "submit": "collect_photos"

  initialize: ->
    @photo_view = new Making.Views.PhotosUpload
    @photo_view.render()

  collect_photos: ->
    $photos = @photo_view.$('.uploaded')

    _.each $photos, (el) =>
      $('<input>').attr(
        name: "thing[photo_ids][]"
        value: $(el).data('photo-id')
        type: "hidden"
      ).appendTo @$el
