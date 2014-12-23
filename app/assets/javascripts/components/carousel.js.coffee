do (exports = Making) ->

  exports.carousel = (options) ->
    that = @
    @defaults =
      element: '.carousel'
    @options = _.extend {}, @defaults, options

    $(@options.element).each ->
      $carousel = $(@)
      $controls = $carousel.find('.carousel-control')

      return true if $carousel.data('carousel')

      options =
        horizontal: true
        itemNav: 'forceCentered'
        smart: true
        activateMiddle: true
        mouseDragging: true
        touchDragging: true
        releaseSwing: true
        cycleBy: 'items'
        pauseOnHover: true
        speed: 300
        keyboardNavBy: 'items'
        disabledClass: 'is-disabled'
      if $controls.length
        $prev = $controls.filter('.left')
        $next = $controls.filter('.right')
        _.extend options,
          prev: $prev
          next: $next

      frame = new Sly(this, options)
      $carousel.data('carousel', frame)

      resetItemWidth = ->
        width = $carousel.css('width')
        $carousel.find('.item').css('width', width)

      $window.on 'resize', ->
        resetItemWidth() if that.options.isResetItemWidth
        frame.reload()

      resetItemWidth() if that.options.isResetItemWidth
      frame.init()

  exports.extendCarousel = ->
    $('.carousel--extend').each ->
      $carousel = $(@)
      $inner    = $carousel.find('.carousel-inner')
      $item     = $inner.children('.item')
      $overview = $carousel.next('.carousel_overview')
      height    = _.min([parseInt($item.css('max-height')), $carousel.width() * 0.75]) + 'px'

      if !$html.hasClass('mobile')
        $item.css
          fontSize: 0
          height: height
          lineHeight: height

      if $overview.length and Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
        $overviewBody = $overview.children('.slideshow_body')

        if $overviewBody.is(':visible')
          carousel       = $carousel.data('carousel')
          $overviewItems = $overviewBody.find('[data-slide-to]')

          $overviewBody.sly
            horizontal: 1
            itemNav: 'centered'
            smart: 1
            activateOn: 'click'
            mouseDragging: 1
            touchDragging: 1
            releaseSwing: 1
            speed: 300
            elasticBounds: 1
            dragHandle: 1
            dynamicHandle: 1
            clickBar: 1
            prevPage: $overview.find('.slideshow_control.left')
            nextPage: $overview.find('.slideshow_control.right')

          $overviewItems.on 'click', ->
            carousel.activate(@getAttribute('data-slide-to'))

          carousel.on 'active', ->
            index = $carousel.find('.carousel-inner').children('.item').filter('.active').index()
            $overview.find('.slideshow_inner').children('li').eq(index).addClass('active').siblings().removeClass('active')

  return exports
