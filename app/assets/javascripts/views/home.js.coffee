window.Making = do (exports = window.Making || {}) ->

  exports.InitHome = (fromId = '') ->
    query = if fromId then '?from_id=#{fromId}' else ''
    exports.infiniteScroll('#feeds', window.location.pathname + query)

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
    switch exports.device
      when 'mobile', 'tablet'
        exports.infiniteScroll('#wrapper > .hits', '/hits')
      else
        exports.initSearchForm('#search_form')

  exports
