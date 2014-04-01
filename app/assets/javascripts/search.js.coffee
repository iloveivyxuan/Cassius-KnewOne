window.Making = do (exports = window.Making || {}) ->

  if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
    url = $('#navbar_search').attr('action') + '.js'
    maxLength = 12
    cache = {}
    isSlideshowInitiated = false
    slideshow = null
    $container = $('#navbar_search')
    $nav_first = $('#navbar_main').children('.navbar-nav').first()
    $input = $('.navbar').find('input[type="search"]')
    $searchCandidate = $('.search_candidate')
    $searchBackdrop = $('.search_backdrop')
    $slideshowBody = $searchCandidate.children('.slideshow_body')
    $list = $slideshowBody.find('.slideshow_inner')
    $keyword = $searchCandidate.find('.search_keyword')
    $prevPage = $searchCandidate.find('.slideshow_control.left')
    $nextPage = $searchCandidate.find('.slideshow_control.right')
    $close = $searchCandidate.children('.close')
    $status = $('#navbar_search').find('[type="search"]').next('.fa')

    $('.navbar').add($searchBackdrop).add($close).on 'click.search', (e)->
      if $searchCandidate.is(':visible')
        $searchCandidate.hide()
        $searchBackdrop.fadeOut()

    $container.on 'submit', (e)->
      if $.trim($input.val()) is ''
        return false
      return true

    $input.on 'keyup', (e)->
      $self = $(@)
      keyword = $.trim @.value

      if keyword.length >= 2
        $status.removeClass('fa-search').addClass('fa-spinner fa-spin')

        if !cache[keyword]
          cache[keyword] = $.ajax
                          url: url
                          data: q: keyword
                          dataType: 'html'
                          contentType: 'application/x-www-form-urlencoded;charset=UTF-8'

        cache[keyword].done (data, status, xhr) ->
          if xhr.status is 200
            link = url.slice(0, -3) + '?q=' + keyword
            $keyword.text(keyword)
            $slideshowBody.css 'width', ->
              $searchCandidate.width()
            $list.empty().html(data)
            if $list.children('li').length >= maxLength
              $more = $('<li />').addClass('more').append($('<a />').attr('href', link).text('更多 ⋯'))
              $list.append($more)

            if !isSlideshowInitiated
              slideshow = new Sly $slideshowBody,
                horizontal: 1
                itemNav: 'centered'
                activateMiddle: 1
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
              .init()
            else
              slideshowBody.slideTo(0)
              slideshow.reload()

            $searchBackdrop.fadeIn()
            $searchCandidate.show()

          else if xhr.status is 204
            $list.empty()
            if slideshow
              slideshow.reload()
              $prevPage.disable()
              $nextPage.disable()

            $keyword.text(keyword)
            $('<li />',
              class: 'empty'
              html: '没有找到，<a href="/things/new">我来分享~</a>'
            )
            .css 'width', -> $slideshowBody.css 'width'
            .appendTo $list

            if $searchBackdrop.is(':hidden') then $searchBackdrop.fadeIn()
            if $searchCandidate.is(':hidden') then $searchCandidate.show()

          $status.removeClass('fa-spinner fa-spin').addClass('fa-search')

        .fail ->
          $searchCandidate.hide()
          $searchBackdrop.fadeOut()
          $status.removeClass('fa-spinner fa-spin').addClass('fa-search')

      else
        if $searchCandidate.is(':visible') and $searchBackdrop.is(':visible')
          $searchCandidate.hide()
          $searchBackdrop.fadeOut()

    if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
      transition_time = parseFloat($container.css('transition-duration')) * 1000

      $input
        .on 'focusin', ->
          if !$container.hasClass('focus')
            if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ') and (max-width: ' + Making.Breakpoints.screenLGMin + ')')
              $nav_first.hide()
            $container.addClass('focus')
        .on 'focusout', ->
          if !$('html').hasClass('csstransitions')
            $nav_first.show()

          $container
            .removeClass('focus')
            .one $.support.transition.end, ->
              if Modernizr.mq '(max-width: ' + Making.Breakpoints.screenLGMin + ')'
                $nav_first.fadeIn()
            .emulateTransitionEnd(transition_time)

  #exports
  exports