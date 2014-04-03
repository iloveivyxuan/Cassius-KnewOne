window.Making = do (exports = window.Making || {}) ->

  if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
    $form      = $('#navbar_search')
    $input     = $form.find('input[type="search"]')
    $status    = $input.next('.fa')
    $candidate = $('.search_candidate')
    $backdrop  = $('.search_backdrop')
    $keyword   = $candidate.find('.search_keyword')
    $close     = $candidate.children('.close')
    url        = $form.attr('action') + '.js'
    cache      = {}
    max_length = 12
    delay       = 300
    typing_time = 0
    $nav_primary    = $('#nav_primary')
    transition_time = parseFloat($form.css('transition-duration')) * 1000

    $('.navbar').add($backdrop).add($close).on 'click.search', (e) ->
      if $candidate.is(':visible')
        $candidate.hide()
        $backdrop.fadeOut()

    $form.on 'submit', (e) ->
      if $.trim($input.val()) is ''
        return false
      return true

    $input.on 'keyup', (e) ->
      $self = $(@)
      keyword = $.trim @.value

      if keyword.length >= 2
        typing_time = new Date()

        setTimeout ->
          if new Date() - typing_time < delay  or
            $.trim($input.val()).length < 2 then return

          $status.removeClass('fa-search').addClass('fa-spinner fa-spin')

          if !cache[keyword]
            cache[keyword] = $.ajax
                            url: url
                            data:
                              q: keyword
                            dataType: 'html'
                            contentType: 'application/x-www-form-urlencoded;charset=UTF-8'

          cache[keyword].done (data, status, xhr) ->
            if xhr.status is 200
              $keyword.text(keyword)

              $(data).each ->
                $data      = $(@)
                $slideshow = $candidate.find('.slideshow.' + $data.attr('class'))
                $body      = $slideshow.find('.slideshow_body')
                $prev_page = $slideshow.find('.slideshow_control.left')
                $next_page = $slideshow.find('.slideshow_control.right')
                link       = url.slice(0, -3) + '?q=' + keyword + '&type=' + $data.attr('class')

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

                  $backdrop.fadeIn()
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
                        '没有找到相关产品，<a href="/things/new">我来分享~</a>'
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

          .fail ->
            $candidate.hide()
            $backdrop.fadeOut()
            $status.removeClass('fa-spinner fa-spin').addClass('fa-search')
        , delay

      else
        if $candidate.is(':visible') and $backdrop.is(':visible')
          $candidate.hide()
          $backdrop.fadeOut()

    .on 'focusin', ->
      if !$form.hasClass('focus')
        if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ') and (max-width: ' + Making.Breakpoints.screenLGMin + ')')
          $nav_primary.hide()
        $form.addClass('focus')

    .on 'focusout', ->
      if !$('html').hasClass('csstransitions')
        $nav_primary.show()
      $form
        .removeClass('focus')
        .one $.support.transition.end, ->
          if Modernizr.mq '(max-width: ' + Making.Breakpoints.screenLGMin + ')'
            $nav_primary.fadeIn()
        .emulateTransitionEnd(transition_time)

    .on 'click', ->
      $(@).select()

  #exports
  exports