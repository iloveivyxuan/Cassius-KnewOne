window.Making = do (exports = window.Making || {}) ->

  exports.InitHome = ->
    Making.InfiniteScroll("#wrapper");

  exports.InitHomeGuest = ->
    $ ->
      $candidate   = $('.search_candidate')
      $tab_trigger = $('.explore').find('[data-toggle="tab"]')
      max          = $tab_trigger.length - 1
      i            = 0

      $('.entry_email_toggle').addClass(if $('.entry_email').is(':visible') then 'active')

      timeout = setInterval ->
        $tab_trigger.eq(++i).tab('show')
        if i is max then i = -1;
      , 10000

      $tab_trigger.on 'click', -> clearTimeout(timeout)

      $('#header').find('[class^="search_"]').remove()
      exports.SearchThing('#search_thing')
      $candidate.css 'top', ->
        $('.explore_header').offset().top + $('.explore_header').outerHeight()
      $(document).on 'click', (event) ->
        $target = $(event.target)
        if !$target.hasClass('search_candidate') and
          $target.parents('.search_candidate').length is 0 and
          !$target.is('#search_thing input[type="search"]')
            $candidate.fadeOut('fast')

  exports
