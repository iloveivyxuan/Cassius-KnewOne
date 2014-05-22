window.Making = do (exports = window.Making || {}) ->

  exports.InitThing = ->
    exports.ReadMore('.post_content')

    switch exports.device

      when 'mobile'
        $carousel = $('#wrapper > .photos')
        $page_num = $carousel.find('.page').find('em')

        $carousel.on 'release', (event) ->
          $page_num.text(
            $carousel
              .find('.carousel-inner')
              .children('.item.active')
              .index() + 1
          )

        exports.CartItemNew()

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
