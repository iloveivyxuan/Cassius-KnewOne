window.Making = do (exports = window.Making || {}) ->

  exports.InitHome = ->
    $container = $('html.signed_in_homepage').find('#activities')
    $spinner = $container.siblings('.spinner')
    $no_content = $container.siblings('.nomore')
    _lock = false
    _page = 1

    loading_timeline =  ->
      $.ajax
        url: '/?page=' + (++ _page)
        dataType: 'html'
        beforeSend: -> _lock = true and $spinner.removeClass('hide')
      .done (data) ->
        if data
          $container.append(data)
          exports.ImageLazyLoading()
          _lock = false
        else
          $no_content.removeClass('hide')
      .always -> $spinner.addClass('hide')

    $ ->
      if $container.children().length is 0
        $no_content.removeClass('hide')

      $(window).on 'scroll', ->
        if $(document).height() - $(window).scrollTop() - $(window).height() < 100 and !_lock
          loading_timeline()

  exports.InitHomeGuest = ->
    $ ->
      $candidate   = $('.search_candidate')
      $tab_trigger = $('.explore').find('[data-toggle="tab"]')
      max          = $tab_trigger.length - 1
      i            = 0

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
