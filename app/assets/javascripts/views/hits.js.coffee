do (exports = window.Making || {}) ->

  exports.InitHits = ->
    exports.scrollSpyPopupLogin('/hits/page/2')
    exports.infiniteScroll('#wrapper .hits', '/hits')

  return exports

