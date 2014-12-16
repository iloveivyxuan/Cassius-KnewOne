window.Making = do (exports = window.Making || {}) ->

  exports.SearchThing = (form) ->
    if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
      $form       = $(form)
      $input      = $form.find('input[type="search"]')
      $status     = $form.find('.fa-search')
      $candidate  = $('.search_candidate')
      $backdrop   = $('.search_backdrop')
      $keyword    = $candidate.find('.search_keyword')
      $close      = $candidate.children('.close')
      url         = $form.attr('action') + '.js'
      cache       = {}
      max_length  = 12
      delay       = 200

      hideSearchSlide = ->
        if $candidate.is(':visible') then $candidate.hide()
        if $backdrop.is(':visible') then $backdrop.fadeOut()
        $status.addClass('fa-search').removeClass('fa-spinner fa-spin')

      $form.on 'submit', (e) ->
        if $.trim($input.val()).length < 1
          return false
        return true

      $input.on 'keyup', _.debounce(->
        $self = $(@)
        keyword = $.trim @.value

        if keyword.length == 0
          hideSearchSlide()
        else
          $status.removeClass('fa-search').addClass('fa-spinner fa-spin')

          if !cache[keyword]
            cache[keyword] = $.ajax
                            url: url
                            data:
                              per_page: max_length
                              q: keyword
                            dataType: 'html'
                            contentType: 'application/x-www-form-urlencoded;charset=UTF-8'

          cache[keyword]
            .done (data, status, xhr) ->
              url_request = decodeURIComponent(@url)
              param = url_request.slice(url_request.lastIndexOf('q=') + 2)

              if xhr.status is 200 and param is $.trim($input.val()).replace(/\ /g, '+')
                if $keyword.length then $keyword.text(keyword)

                $(data).each ->
                  $data      = $(@)
                  $slideshow = $candidate.find('.slideshow.' + $data.attr('class'))
                  $body      = $slideshow.find('.slideshow_body')
                  $prev_page = $slideshow.find('.slideshow_control.left')
                  $next_page = $slideshow.find('.slideshow_control.right')
                  link       = url.slice(0, -3) + '?q=' + keyword + '&type=' + $data.attr('class')

                  if $slideshow.length is 0 then return

                  if $data.children('li').length > 0

                    if $data.children('li').length >= max_length
                      $('<li />')
                        .addClass('more')
                        .append(
                          $('<a />')
                            .attr('href', link)
                            .text('更多 ⋯')
                          )
                        .appendTo($data)

                    $body
                      .css 'width', ->
                        $candidate.width() - $prev_page.width() - $next_page.width()
                      .empty()
                      .append($data.addClass('slideshow_inner'))

                    slideshow = $slideshow.data('slideshow')
                    if slideshow isnt undefined
                      slideshow.destroy()
                    slideshow = new Sly $body,
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
                      prevPage: $prev_page
                      nextPage: $next_page
                    .init()
                    $slideshow.data('slideshow', slideshow)

                    if $backdrop.length then $backdrop.fadeIn()
                    $candidate.show()

                  else

                    $body = $slideshow.find('.slideshow_body')
                    $prev_page = $slideshow.find('.slideshow_control.left')
                    $next_page = $slideshow.find('.slideshow_control.right')
                    slideshow = $slideshow.data('slideshow')

                    $body.empty().css('width', '100%')

                    if slideshow
                      slideshow.reload()
                    $prev_page.disable()
                    $next_page.disable()

                    $('<li />')
                      .addClass('empty')
                      .html ->
                        if $data.hasClass('things')
                          '没有找到相关产品' +
                            if $('#user').length
                              '，<a href="/things/new">我来分享~</a>'
                            else
                              '。'
                        else if $data.hasClass('users')
                          '没有找到相关用户。'
                      .css 'width', -> $body.css 'width'
                      .appendTo($data)

                    $data
                      .addClass('slideshow_inner')
                      .appendTo($body)

                  if $backdrop.is(':hidden') then $backdrop.fadeIn()
                  if $candidate.is(':hidden') then $candidate.show()
                  $status.removeClass('fa-spinner fa-spin').addClass('fa-search')

            .fail hideSearchSlide
      , delay)

  $ ->
    if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenMDMin + ')')
      $form       = $('#navbar_search')
      $input      = $form.find('input[type="search"]')
      $candidate  = $('.search_candidate')
      $backdrop   = $('.search_backdrop')
      $close      = $candidate.children('.close')
      $nav_primary    = $('#nav_primary')
      transition_time = parseFloat($form.css('transition-duration')) * 1000
      _focusOutSearch = ->
        $candidate.hide()
        $backdrop.fadeOut()

        if !$('html').hasClass('csstransitions')
          $nav_primary.show()
        $form
          .one $.support.transition.end, ->
            if Modernizr.mq '(min-width: ' + Making.Breakpoints.screenSMMin + ')'
              $nav_primary.fadeIn()
          .emulateTransitionEnd(transition_time)

      exports.SearchThing('#navbar_search')

      $('.navbar').add($backdrop).add($close).on 'click.search', (e) ->
        if e.target is $input[0] then return
        _focusOutSearch()

      $input
        .on 'focusout', ->
          _focusOutSearch()
        .on 'click', ->
          $(@).select()

  exports
