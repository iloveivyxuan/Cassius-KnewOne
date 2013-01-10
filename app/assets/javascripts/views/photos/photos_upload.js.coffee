class Making.Views.PhotosUpload extends Backbone.View

  tagName: "ul"

  initialize: ->
    @$container = $("#photos")
    @collection = new Making.Collections.Photos(@$container.data('photos'))
    @collection.on
      add: @append
    $('#new_photo').fileupload
      dataType: "json"
      done: @done

  render: =>
    @collection.each @append
    @$container.html @el
    this

  append: (photo) =>
    view = new Making.Views.Photo(model: photo)
    @$el.append view.render().el

  done: (e, data) =>
    @append data.result


