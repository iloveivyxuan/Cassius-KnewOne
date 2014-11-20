class Making.Views.PhotosUpload extends Backbone.View

  tagName: 'ul'

  events:
    "click .destroy": "checkQueue"

  initialize: ->
    @$container = $("#photos")
    @$label = @$container.closest('.uploader').find('.uploader_label')
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
    @$container.prepend @el
    this

  addFile: (e, data) =>
    @$container.find('.help-block').hide()
    file = data.files[0]
    data.view = new Making.Views.PhotoPreview
      model: file
    @$el.prepend data.view.render().el
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
    data.view.$el
      .removeClass('uploading')
      .addClass('fail')
      .html('<p class="fail">出错了，再试试。<a class="destroy" title="删除" href="#"><i class="fa fa-trash-o"></i></a></p>')
    @checkUploaderButton()
    false

  addPhoto: (photo, collection, options) =>
    view = new Making.Views.Photo
      model: photo
      attributes:
        'data-photo-id': photo.id
    if options.add
      @$el.prepend view.render().el
    else
      @$el.append view.render().el
    @checkQueue()
    @$el.sortable
      items: '.uploaded'

  removePhoto: =>
    if @$el.children('li').length is 0
      @$el.prev('.help-block').show()

  checkQueue: =>
    that = @
    if @$el.children('li:not(.uploader_button)').length is 0
      @$el.children('.uploader_button').remove()
      @$label.removeClass('is-valid')
    else
      $uploader_button = @$el.children('.uploader_button')
      @$label.addClass('is-valid')
      if $uploader_button.length is 0
        $button = $('<li class="uploader_button">+</li>')
        $button.on 'click', ->
          that.$el.closest('.uploader').find('.uploader_label').click()
        @$el.append($button)
      else
        @$el.append($uploader_button)
