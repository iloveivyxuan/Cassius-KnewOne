do (exports = Making) ->

  exports.carousel = (options) ->
    that = @
    @defaults =
      element: '.carousel'
    @options = _.extend {}, @defaults, options

    $(@options.element).each ->
      $carousel = $(this)
      $controls = $carousel.find('.carousel-control')
      $carouselBody = $carousel.find('.carousel-inner')

      return if $carouselBody.data('carousel')

      $carouselBody.slick
        autoplay: true
        autoplaySpeed: 2000
        prevArrow: $controls.filter('.left')[0]
        nextArrow: $controls.filter('.right')[0]

      $carousel.data('carousel', $carouselBody.slick('getSlick'))

      if that.options.isResetItemWidth
        $carousel.addClass('reset-size')

        resetItemWidth = do ->
          width = $carousel.css('width')
          height = $carousel.css('height')
          $carouselBody.find('.item') .css(width: width, height: height, lineHeight: height)
          arguments.callee

        $window.on 'resize', ->
          resetItemWidth() if that.options.isResetItemWidth

  exports.extendCarousel = ->
    $('.carousel--extend').each ->
      $carousel = $(this)
      $carouselBody = $carousel.find('.carousel-inner')
      $item     = $carouselBody.children('.item')
      $overview = $carousel.next('.carousel_overview')
      $overviewBody = $overview.children('.slideshow_body')
      $carouselNav = $overview.find('.slideshow_inner')
      $slideshowControl = $overview.find('.slideshow_control')

      height    = _.min([parseInt($item.css('max-height')), $carousel.width() * 0.75]) + 'px'

      if !$html.hasClass('mobile')
        $item.css
          fontSize: 0
          height: height
          lineHeight: height

      if $overview.length and Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
        if $overviewBody.is(':visible')
          $overviewItems = $overviewBody.find('[data-slide-to]')
          $overviewItems.eq(0).addClass('active')

          slideNum = parseInt($carouselNav.width() / 70)
          slideNum = if $overviewItems.length < slideNum then $overviewItems.length else slideNum

          $carouselNav.slick
            prevArrow: $slideshowControl.filter('.left')[0]
            nextArrow: $slideshowControl.filter('.right')[0]
            slidesToShow: slideNum
            slidesToScroll: slideNum
            fixedWidth: 70
            infinite: false

          $carouselNav.on 'click', '[data-slide-to]', ->
            $carouselBody.slick('slickGoTo', @getAttribute('data-slide-to'))
            

          $carouselBody.on 'afterChange', (e, slick, index) ->
            $overviewItems.eq(index).addClass('active').siblings().removeClass('active')
            

  return exports