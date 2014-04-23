window.Making = do (exports = window.Making || {}) ->
  _$content       = $('#thing_content').find('.post_content')
  _$read_more     = _$content.next('.more').children('a')
  _summary_height = parseInt(_$content.css('maxHeight')) - 1

  exports.InitThing = ->
    if _$content.height() < _summary_height
      _$content
        .removeClass('is_folded')
        .next('.more')
          .remove()

    _$read_more.on 'click', (event) ->
      event.preventDefault()

      $element = $(@).parents('.more')
      $element
        .prev('.post_content')
          .removeClass('is_folded')
        .end()
        .remove()

  exports.InitFeelings = ->
    exports.EditorCompact('.feeling_form')

  #exports
  exports