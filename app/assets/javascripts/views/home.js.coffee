window.Making = do (exports = window.Making || {}) ->

  exports.InitHome = (fromId = '') ->
    query = if fromId then "?from_id=#{fromId}" else ''
    exports.infiniteScroll('#feeds', window.location.pathname + query)

    Making.Feeling("#feeds")

  exports.InitHomeGuest = (options = {}) ->
    options = $.extend {}, exports.InitHomeGuest.OPTIONS, options
    switch exports.device
      when 'mobile', 'tablet'
        exports.infiniteScroll('#wrapper > .hits', options.url)
      else
        exports.initSearchForm('#search_form')

    $(document).on 'click', '.sign_group .btn', (e) ->
      $this = $(this)
      $modal = $('#login-modal')
      $wrapper = $modal.find('.modal-dialog_wrapper')

      if $this.hasClass('btn--signin')
        $wrapper.removeClass('is-flipped')
      else
        $wrapper.addClass('is-flipped')

  exports.InitHomeGuest.OPTIONS = {
    url: '/hits'
  }

  exports
