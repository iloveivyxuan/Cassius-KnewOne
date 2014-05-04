window.Making = do (exports = window.Making || {}) ->
  _$content       = $('#thing_content').find('.post_content')
  _$read_more     = _$content.next('.more')
  _summary_height = parseInt(_$content.css('maxHeight')) - 1

  exports.InitThing = ->
    if _$content.height() < _summary_height
      _$content
        .removeClass('is_folded')
        .next('.more')
          .remove()

    _$read_more.on 'click', (event) ->
      event.preventDefault()

      $(@)
        .prev('.post_content')
          .removeClass('is_folded')
        .end()
        .remove()

  exports.InitFeelings = ->
    exports.EditorCompact('.feeling_form')
    # TODO Merge into EditorCompact.
    exports.FeelingsNew()
    exports.Feeling('.feelings')

  exports.Feeling = (container) ->
    _$container = $(container)

    _$container
      .on 'click', '.comments_toggle', (event) ->
        event.preventDefault()

        id = '#' + $(@).data('id')
        $element = $(id)
        $wrapper = $element.parents('.comments_wrap')

        if $wrapper.is(':hidden')
          exports.Comments(id)
          $element.show()
          $wrapper.show()
        else
          $wrapper.hide()

  #exports
  exports