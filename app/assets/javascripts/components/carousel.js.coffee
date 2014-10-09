do (exports = Making) ->

  exports.ExtendCarousel = ->
    $('.carousel--extend').each ->
      $carousel      = $(@)
      $inner         = $carousel.find('.carousel-inner')
      $item          = $inner.children('.item')
      default_height = parseInt($item.css('max-height'))
      height         = _.min([default_height, $inner.width() * 0.75]) + 'px'
      $overview      = $carousel.next('.carousel_overview')

      if !$html.hasClass('mobile')
        $item.css
          fontSize: 0
          height: height
          lineHeight: height

      if $overview.length and Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
        $overview_body = $overview.children('.slideshow_body')

        if $overview_body.length and $overview_body.is(':visible')
          $prevPage = $overview.find('.left')
          $nextPage = $overview.find('.right')

          $overview_body.sly
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
            prevPage: $prevPage
            nextPage: $nextPage

          $carousel.on 'slid.bs.carousel', ->
            index = $(@).find('.carousel-inner').children('.item').filter('.active').index()
            $overview.find('.slideshow_inner').children('li').eq(index).addClass('active').siblings().removeClass('active')

  $ ->
    if $('.carousel').length
      Making.ExtendCarousel()
      $(window).on 'resize.bs.carousel.data-api', ->
        if !lock
          lock = true
          Making.ExtendCarousel()
          lock = false

      if $html.hasClass('touch')
        $('.carousel').each ->
          $this  = $(@)
          hammer = new Hammer(@)

          hammer
            .on 'swipeleft', ->
              $this.carousel('next')
            .on 'swiperight', ->
              $this.carousel('prev')

  return exports
