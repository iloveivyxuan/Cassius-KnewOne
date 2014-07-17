window.Making = do (exports = window.Making || {}) ->

  exports.InitHome = ->
    Making.InfiniteScroll("#wrapper")

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

  exports
