window.Making = do (exports = window.Making || {}) ->

  exports.EditorCompact = (element) ->
    _$element         = $(element)
    _$editor          = _$element.find('.editor_compact')
    _$content         = _$editor.find('.editor_content')
    _$uploader_button = _$element.find('#photo_image')
    _$uploader_queue  = _$element.find('.uploader_queue')

    exports.Rating()

    _$element
      .on 'click', '.uploader_button', ->
        if !_$editor.hasClass('uploading')
          _$editor.addClass('uploading')

    _$uploader_button.on 'fileuploadadd', ->
      height = _$uploader_queue.outerHeight()

      _$uploader_queue.css marginTop: - (119 + height)
      _$content.css paddingBottom: height

  #exports
  exports
