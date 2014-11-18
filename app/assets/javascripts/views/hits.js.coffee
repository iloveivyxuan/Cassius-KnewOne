do (exports = window.Making || {}) ->

  exports.InitHits = ->
    exports.infiniteScroll('#wrapper .hits', '/hits')

  return exports

