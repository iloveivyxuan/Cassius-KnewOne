class Making.Views.PhotoPreview extends Backbone.View

  tagName: 'li'
  className: 'uploading'
  template: HandlebarsTemplates['photos/preview']

  events:
    "click .destroy": "remove"

  initialize: ->
    @model.readable_size = @_formatSize(@model.size)

  render: =>
    @$el.html @template(@model)
    loadImage @model, (img) =>
      @$(".uploader_item").prepend img
    , {
      canvas: true
      maxWidth: @$('.uploader_item').data('preview-width')
      maxHeight: @$('.uploader_item').data('preview-height')
    }
    this

  validate: =>
    types = /(\.|\/)(gif|jpe?g|png)$/i
    size = 5000000
    unless types.test(@model.type) || types.test(@model.name)
      return @fail "需要图片格式文件"
    if _.isNumber(@model.size) and @model.size > size
      return @fail "图片大小限制为#{@_formatSize(size)}"
    true

  progress: (data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    @$('.progress .progress-bar').css('width', progress + '%')

  fail: (error) ->
    @$el
      .removeClass('uploading')
      .addClass('fail')
      .html('<p class="fail">' + error +
        '<a class="destroy" title="删除" href="javascript:;"><i class="fa fa-trash-o"></i></a></p>')
      .closest('form')
        .trigger('fail.validation')
    false

  _formatSize: (bytes) ->
    return '' unless _.isNumber(bytes)
    if bytes >= 1000000
      (bytes / 1000000).toFixed(2) + ' MB'
    else
      (bytes / 1000).toFixed(2) + ' KB';
