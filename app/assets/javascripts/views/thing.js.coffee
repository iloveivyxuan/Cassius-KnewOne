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
      excludeField: '[name="utf8"], [name="authenticity_token"], [name="photo[image]"]'
      placeholder: '产品详细信息'

  exports.InitThings = ->
    exports.infiniteScroll '.infinite', window.location.href, (data, xhr) ->
      $(data).find(".lazy").css("visibility", "visible").lazyload
        threshold: 400
      return
    return

  exports.InitThing = ->
    exports.ReadMore('.post_content')
    exports.InitAdoption()

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

        $carousel.on 'slid.bs.carousel swipeleft swiperight', (event) ->
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

  exports.InitShop = ->
    exports.scrollSpyPopupLogin(window.location.pathname + '/page/2')
    exports.infiniteScroll('.js-infinite', window.location.pathname)
    $('#things_nav select').on 'change', (event) ->
      window.location = $(this).find(':selected').data('url')

  exports.InitAdoption = ->
    if !$html.hasClass('mobile')
      $adoption      = $('#thing_actions #adoption-modal')
      $adoptionKind  = $adoption.find('[name="adoption[kind]"]')

      $('[data-target="#adoption-modal"]').on 'click', (event) ->
        $cartKind  = $('[name="cart_item[kind_id]"]')
        $adoptionKind.val($cartKind.val())

    requireAddress = (required) ->
      $(['#adoption_address_province'
         '#adoption_address_district'
         '#adoption_address_street'
         '#adoption_address_name'
         '#adoption_address_phone'].join(', ')).prop('required', required)

    $('[name="adoption[address_id]"]').on('change', ->
      required = $('#adoption_address_id_new').prop('checked')
      requireAddress(required)
    )

    $('[name^="adoption[address]"]').on('focus', ->
      $('#adoption_address_id_new').prop('checked', true)
      requireAddress(true)
    )

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
