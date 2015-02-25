window.Making = do (exports = window.Making || {}) ->

  exports.InitHome = (fromId = '') ->
    query = if fromId then "?from_id=#{fromId}" else ''
    exports.infiniteScroll('#feeds', window.location.pathname + query)

    Making.Feeling("#feeds")

  exports.InitHomeGuest = ->
    switch exports.device
      when 'mobile', 'tablet'
        exports.infiniteScroll('#wrapper > .hits', '/hits')
      else
        exports.initSearchForm('#search_form')

  exports
