window.Making = do (exports = window.Making || {}) ->

  exports.EditorCompact = (element) ->
    _$element         = $(element)
    _$editor          = _$element.children('.editor_compact')
    _$content         = _$editor.find('.editor_content')
    _$uploader        = _$element.children('.uploader')
    _$uploader_button = _$element.find('#photo_image')
    _$uploader_queue  = _$element.find('.uploader_queue')
    deferred_reset    = new $.Deferred()

    exports.Rating()

    _$element
      .on 'click', '.uploader_button', ->
        if !_$editor.hasClass('uploading')
          _$editor.addClass('uploading')

      .on 'fileuploadsubmit', ->
        height = _$uploader_queue.outerHeight()

        _$uploader_queue.css marginTop: - (70 + height)
        _$content.css paddingBottom: height

    deferred_reset
      .done () ->
        _$editor[0].reset()
        _$uploader[0].reset()

        _$editor
          .find('.rating').children('.star').removeClass('selected')
          .find('[name*="[photo_ids]"]').remove()

        _$uploader.find('.uploader_item .destroy').trigger('click')
        _$uploader_queue.removeAttr('style')
        _$content.removeAttr('style')

    _$element.data('reset', deferred_reset)

  #exports
  exports
