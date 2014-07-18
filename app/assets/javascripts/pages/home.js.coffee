window.Making = do (exports = window.Making || {}) ->

  exports.InitHome = ->
    Making.InfiniteScroll("#wrapper")

    $(document)
    .on('submit', '.feed-feeling .comment-form', (event) ->
      $form = $(this)

      event.preventDefault()

      $.post($(this).attr('action'), $(this).serialize())
      .done(->
        Making.ShowMessageOnTop('评论成功！')

        $form
        .trigger('reset')
        .siblings('.feed-counts')
        .find('.feed-comments')
          .trigger('click')
          .find('.comments-count')
            .text(-> (parseInt($(this).text()) || 0) + 1)
      )
      .fail(->
        Making.ShowMessageOnTop('发送失败，请重试', 'warning')
      )
    )
    .on('click', '.feed-feeling .feed-comments', (event) ->
      event.preventDefault()

      $(this)
      .toggleClass('active')
      .closest('.feed-feeling').find('.comment-form')
      .slideToggle()
    )
    .on('click', '.feed-feeling .feed-lovers', (event) ->
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

  exports
