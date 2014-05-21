window.Making = do (exports = window.Making || {}) ->

  exports.InitThing = ->
    exports.ReadMore('.post_content')

    if $html.hasClass('mobile')
      $frame = $('#wrapper > .photos')
      $page  = $frame.find('.page')
      $num   = $page.find('em')

      $frame
        .children('ul')
        .children('li')
          .css('width', $frame.width())
      frame = new Sly $frame,
        horizontal: 1
        itemNav: 'forceCentered'
        smart: 1
        activateMiddle: 1
        mouseDragging: 1
        touchDragging: 1
        releaseSwing: 1
        startAt: 0
        scrollBy: 1
        speed: 300
        elasticBounds: 1
        dragHandle: 1
        dynamicHandle: 1
        clickBar: 1
      .init()
      frame.on 'active', (event, index)->
        $num.text(index + 1)

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
