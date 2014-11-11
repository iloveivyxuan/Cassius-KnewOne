window.Making = do (exports = window.Making || {}) ->

  exports.EditorCompact = (element) ->
    _$element         = $(element)
    _$editor          = _$element.children('.editor_compact')
    _$content         = _$editor.find('.editor_content')
    _$textarea        = _$content.children('textarea')
    _$uploader        = _$element.children('.uploader')
    _$uploader_button = _$element.find('#photo_image')
    _$uploader_queue  = _$element.find('.uploader_queue')
    _$counter         = _$editor.find('.counter')
    _$button          = _$editor.find('[type="submit"]')
    deferred_reset    = new $.Deferred()

    _reset = (deferred) ->
      deferred
        .done () ->
          _$editor[0].reset()
          _$uploader[0].reset()

          _$editor
            .find('.rating').children('.star').removeClass('selected')
            .find('[name*="[photo_ids]"]').remove()

          _$content.removeAttr('style')
          _$counter.text(maxlength) if (maxlength = parseInt(_$textarea.data('maxlength'))) isnt 0
          _$uploader_queue
            .removeAttr('style')
            .children('ul')
            .empty()
          _$button.button('reset')

    _setUploaderHeight = ->
      height = _$uploader_queue.outerHeight()

      _$uploader_queue.css marginTop: - (70 + height)
      _$content.css paddingBottom: height

    exports.Rating()

    _$element
      .on 'click', '.uploader_button', ->
        if !_$editor.hasClass('uploading')
          _$editor.addClass('uploading')

      .on 'fileuploadsubmit', _setUploaderHeight

      .on 'submit', '.editor_compact', ->
        deferred_reset = new $.Deferred()
        _reset(deferred_reset)
        _$element.data('reset', deferred_reset)

    _$uploader.on 'fail.validation', _setUploaderHeight

    _reset(deferred_reset)
    _$element.data('reset', deferred_reset)

  #exports
  exports
