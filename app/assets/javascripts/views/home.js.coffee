window.Making = do (exports = window.Making || {}) ->

  exports.InitHome = ->
    Making.InfiniteScroll("#wrapper")

    Making.Feeling("#feeds")

    $(document)
    .on('click', '.feed-feeling .feed-comments', ->
      $(this).toggleClass('active')
    )
    .on('click', '.feed-operations .feed-lovers', (event) ->
      $this = $(this)

      event.preventDefault()

      if $this.hasClass('active')
        action = 'unvote'
        increment = -1
      else
        action = 'vote'
        increment = 1

      $.post("#{$(this).data('url')}/#{action}")
      .done(->
        $this
        .toggleClass('active')
        .find('.lovers-count')
          .text(-> (parseInt($(this).text()) || 0) + increment)
      )
    )

  exports.InitHomeGuest = ->
    popupLogin = ->
      $window.on 'scroll.login', ->
        if $document.height() - $window.scrollTop() - $window.height() < 100
          $('#header [data-target="#login-modal"]').trigger('click')
          $window.off 'scroll.login'

    if $html.hasClass('mobile')
      popupLogin()
    else if $html.hasClass('tablet')
      popupLogin()
    else if $html.hasClass('desktop')
      $candidate   = $('.search_candidate')
      $('#header').find('[class^="search_"]').remove()
      exports.SearchThing('#search_form')
      $candidate.css 'top', ->
        $('.explore_header').offset().top + $('.explore_header').outerHeight()
      $(document).on 'click', (event) ->
        $target = $(event.target)
        if !$target.hasClass('search_candidate') and
          $target.parents('.search_candidate').length is 0 and
          !$target.is('#search_thing input[type="search"]')
            $candidate.fadeOut('fast')

  exports
