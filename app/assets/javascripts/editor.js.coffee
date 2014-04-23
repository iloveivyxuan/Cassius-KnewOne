window.Making = do (exports = window.Making || {}) ->

  exports.EditorCompact = (element) ->
    _$element = $(element)
    _$editor  = _$element.find('.editor_compact')

    exports.Rating()

    _$element
      .on 'click', '.uploader_button', ->
        if !_$editor.hasClass('uploading')
          _$editor.addClass('uploading')

  #exports
  exports