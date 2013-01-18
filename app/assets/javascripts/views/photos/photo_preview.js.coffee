class Making.Views.PhotoPreview extends Backbone.View

  tagName: 'li'
  className: 'uploading'
  template: JST['photos/preview']

  events: 
      "click .fail a": "remove"

  initialize: ->
    @model.readable_size = @_formatSize(@model.size)
  
  render: =>
    @$el.html @template(@model)
    loadImage @model, (img) =>
      @$(".photo").prepend img
    , {
      canvas: true
      maxWidth: @$('.photo').data('preview-width')
      maxHeight: @$('.photo').data('preview-height')
    } 
    this

  validate: =>
    types = /(\.|\/)(gif|jpe?g|png)$/i
    size = 5000000
    unless types.test(@model.type) || types.test(@model.name)
      return @fail "需要图片格式文件"
    unless @model.size < size
      return @fail "图片大小限制为#{@_formatSize(size)}"
    true

  progress: (data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    @$('.progress .bar').css('width', progress + '%')

  fail: (error) ->
    @$('.progress').replaceWith "<p class=\"fail\">#{error}, 请<a href='#'>重新上传</a></p>"
    false

  _formatSize: (bytes) ->
    return '' unless _.isNumber(bytes)
    if bytes >= 1000000
      (bytes / 1000000).toFixed(2) + ' MB'
    else
      (bytes / 1000).toFixed(2) + ' KB';      



