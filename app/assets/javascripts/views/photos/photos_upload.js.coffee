class Making.Views.PhotosUpload extends Backbone.View

  tagName: "ul"

  initialize: ->
    @$container = $("#photos")
    @collection = new Making.Collections.Photos(@$container.data('photos'))
    @collection.on
      add: @addPhoto
      remove: @removePhoto
    $('#new_photo').fileupload
      dataType: "json"
      paramName: 'photo[image]' #rails 3.2.13 breaks multiple file upload, waiting for fixed
      add: @addFile
      dragover: @dragover
      drop: @drop
      progress: @progress
      done: @done
      fail: @fail

  render: =>
    @collection.each @addPhoto
    @$container.append @el
    this

  addFile: (e, data) =>
    @$container.find('.help-block').hide()
    file = data.files[0]
    data.view = new Making.Views.PhotoPreview
      model: file
    @$el.append data.view.render().el
    if data.view.validate()
      data.submit()

  dragover: (e) =>
    @$container.addClass("dragover")

  drop: (e) =>
    @$container.removeClass("dragover")

  progress: (e, data) =>
    data.view.progress data

  done: (e, data) =>
    data.view.remove()
    @collection.add data.result

  fail: (e, data) =>
    result = $.parseJSON(data.jqXHR.responseText)
    data.view.fail result.errors.image[0]

  addPhoto: (photo) =>
    view = new Making.Views.Photo
      model: photo
      attributes:
        'data-photo-id': photo.id
    @$el.append view.render().el
    @$el.sortable
      items: '.uploaded'

  removePhoto: =>
    if @$el.children('li').length is 0
      @$el.prev('.help-block').show()
