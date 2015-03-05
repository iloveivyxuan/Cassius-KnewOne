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
      $items = $('.explore_content_item')
      $navs  = $('.explore_nav li')
      $activeItem = $items.filter('.active')
      $activeNav  = $navs.filter('.active')
      itemsLength = $items.length
      activeIndex = $items.index($activeItem)
      offsetStart = 0
      offsetEnd = 0

      $('.explore_body').on 'touchstart touchend', (event) ->
        touch = event.originalEvent.changedTouches[0]
        if event.type is 'touchstart'
          offsetStart = touch.clientX
        else
          offsetEnd = touch.clientX
          if offsetEnd - offsetStart < -100 && activeIndex < itemsLength - 1
            activeIndex += 1
          else if offsetEnd - offsetStart > 100 && activeIndex > 0
            activeIndex -= 1
          else
            return
          updateExplore()

      $navs.on 'click', ->
        $activeNav = $(this)
        activeIndex = $navs.index($activeNav)
        $activeItem = $items.eq(activeIndex)

      $(document).on 'click', '.switch_explore_content' , (e) ->
        $this = $(this)
        if $this.hasClass('left')
          return unless activeIndex > 0
          activeIndex -= 1
        else if activeIndex < itemsLength - 1
          activeIndex += 1
        else
          return
        updateExplore()

      updateExplore = ->
        $activeItem.removeClass('active in')
        $activeNav.removeClass('active')
        $activeItem = $items.eq(activeIndex).addClass('active')
        $activeNav  = $navs.eq(activeIndex).addClass('active')
        setTimeout ->
          $activeItem.addClass('in')
        , 0

      $(document).on 'click', '.nav_toggle-btn', ->
        $('.explore_nav').toggleClass('open')

  exports.InitHomeGuest.OPTIONS = {
    url: '/hits'
  }

  exports
