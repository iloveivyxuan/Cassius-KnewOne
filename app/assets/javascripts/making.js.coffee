window.Making =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  initialize: -> 

  UploadPhotos: (el) ->
    $(document).ready ->
      view = new Making.Views.PhotosUpload
      view.render()

$(document).ready ->
  Making.initialize()
