window.Making = do (exports = window.Making || {}) ->

  exports.InitHome = (fromId = '') ->
    query = if fromId then "?from_id=#{fromId}" else ''
    exports.infiniteScroll('#feeds', window.location.pathname + query)

    Making.Feeling("#feeds")

  exports.InitHomeGuest = (options = {}) ->
    options = $.extend {}, exports.InitHomeGuest.OPTIONS, options

    if $('html').hasClass('mobile')
      switch exports.device
        when 'mobile', 'tablet'
          exports.infiniteScroll('#wrapper > .hits', options.url)
        else
          exports.initSearchForm('#search_form')

    if $('html').hasClass('tablet')
      $(document).on 'click', '.nav_toggle-btn', ->
        $('.explore_nav').toggleClass('open')

      $slick = $('.explore_content').slick
        arrows: false
      $('.explore_content_item').css('display', 'block')

      $navs = $('.explore_nav li')
      activeSlide = 0

      $slick.on 'afterChange', (e, slick, currentSlide) ->
        $navs.eq(activeSlide).removeClass('active')
        $navs.eq(currentSlide).addClass('active')
        activeSlide = currentSlide

      $navs.on 'click', ->
        clickedSlide = $navs.index(this)
        return if clickedSlide == activeSlide
        $slick.slick('slickGoTo', clickedSlide)
        activeSlide = clickedSlide

  exports.InitHomeGuest.OPTIONS = {
    url: '/hits'
  }

  exports
