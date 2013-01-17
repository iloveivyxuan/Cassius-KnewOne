class Making.Views.PhotoPreview extends Backbone.View

  tagName: 'li'
  className: 'uploading'
  template: JST['photos/preview']

  initialize: ->
    @model.readable_size = @_formatSize(@model.size)
  
  render: =>
    
    @$el.html @template(@model)
  
    loadImage @model, (img) =>
      @$(".preview").prepend img
    , {
      canvas: true
      maxWidth: @$('.preview').data('preview-width')
      maxHeight: @$('.preview').data('preview-height')
    } 

    this

  progress: (data) ->
    progress = parseInt(data.loaded / data.total * 100, 10)
    @$('.progress .bar').css('width', progress + '%')

  _formatSize: (bytes) ->
    return '' unless _.isNumber(bytes)
    if bytes >= 1000000
      (bytes / 1000000).toFixed(2) + ' MB'
    else
      (bytes / 1000).toFixed(2) + ' KB';      



