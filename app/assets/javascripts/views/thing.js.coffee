window.Making = do (exports = window.Making || {}) ->

  exports.InitNewThing = ->
    new exports.Views.ThingsNew
      el: "form.thing_form"

    new exports.Views.Editor
      el: '#form-thing'
      model: new exports.Models.Editor()
      mode: 'standalone'
      type: 'thing'
      bodyField: '[name="thing[content]"]'
      excludeField: '[name="photo[image]"]'
      placeholder: '产品详细信息'

    exports.FormLink('form.thing_form', '#thing_form_submit button')

  exports.InitThing = ->
    exports.ReadMore('.post_content')

    # TODO
    if $html.hasClass('touch')
      $window.on 'load', ->
        $player = $('.is_folded .fluid-width-video-wrapper')

        $player
          .css
            'height': $player.css('height')
            'width': $player.css('width')
            'position': 'absolute'
            'left': '-1000%'
            'overflow': 'hidden'
        $('.post_content').next('.more').on 'click', ->
          $player.css
            'position': 'relative'
            'left': 0

    switch exports.device

      when 'mobile'
        $carousel = $('#wrapper > .photos')
        $page_num = $carousel.find('.page').find('em')

        $carousel.on 'swipeleft swiperight', (event) ->
          $page_num.text(
            $carousel
              .find('.carousel-inner')
              .children('.item.active')
              .index() + 1
          )

        $('#toggle_feelings_form').on 'click', (event) ->
          event.preventDefault()
          $(@).hide()
          $('.feeling_form').show()

        new exports.View.Stream('#feelings')
        new exports.View.Stream('#reviews')
        if $html.hasClass('things_show') then exports.InitFeelings()
        exports.CartItemNew()
        $('.feeling_form')
          .on 'click', '[type="submit"]', ->
            $(@)
              .parents('.feeling_form')
              .next('.stream_content')
              .next('.nomore')
              .hide()

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
