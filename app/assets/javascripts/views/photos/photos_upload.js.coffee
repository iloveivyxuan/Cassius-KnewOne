class Making.Views.PhotosUpload extends Backbone.View

  tagName: "ul"

  initialize: ->
    @$container = $("#photos")
    @collection = new Making.Collections.Photos(@$container.data('photos'))
    @collection.on
      add: @addPhoto
    $('#new_photo').fileupload
      dataType: "json"
      dropzone: @$container
      # dragover: =>
      #   @$container.addClass('dragover')
      # drop: =>
      #   @$container.removeClass('dragover')
      add: @addFile
      progress: @progress
      done: @done
      fail: @fail

  render: =>
    @collection.each @addPhoto
    @$container.append @el
    this

  addFile: (e, data) =>
    file = data.files[0]
    data.view = new Making.Views.PhotoPreview
      model: file
    @$el.append data.view.render().el
    data.submit()

  progress: (e, data) =>
    data.view.progress data

  done: (e, data) =>
    data.view.remove()
    @collection.add data.result

  addPhoto: (photo) =>
    view = new Making.Views.Photo
      model: photo
      attributes:
        'data-photo-id': photo.id
    @$el.append view.render().el  
    @$el.sortable
      items: '.uploaded'

