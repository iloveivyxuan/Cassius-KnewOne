class Making.Views.ThingsNew extends Backbone.View

  events:
    "submit": "collect_photos"

  initialize: ->
    @photo_view = new Making.Views.PhotosUpload
    @photo_view.render()

  validate_photos: ->
    console.log "validate"

  collect_photos: ->
    $photos = @photo_view.$('.uploaded')
    if $photos.length == 0
      $('.fileinput-button').tooltip('show')
      return false

    _.each $photos, (el) =>
      $('<input>').attr(
        name: "thing[photo_ids][]"
        value: $(el).data('photo-id')
        type: "hidden"
      ).appendTo @$el
