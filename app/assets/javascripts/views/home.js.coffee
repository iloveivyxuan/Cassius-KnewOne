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
    $ ->
      $('.entry_email_toggle').addClass(if $('.entry_email').is(':visible') then 'active')

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

      if localStorage.getItem('unlimited') isnt 'false'
        $('a[data-target="#login-modal"]').each ->
          $this = $(@)
          $this
            .attr('href': $this.attr('data-link'))
            .removeAttr('data-toggle')
        $window.on 'beforeunload', ->
          localStorage.setItem('unlimited', 'false')

      exports.setRedirection()

  exports.setRedirection = ->
    $('#login-modal').on 'shown.bs.modal', (event) ->
      $click_from = event.relatedTarget.getAttribute('data-link')
      rf.setAttribute('value', $click_from) for rf in $('[id="redirect_from"]')

  exports
