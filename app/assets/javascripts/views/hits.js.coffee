do (exports = window.Making || {}) ->

  exports.InitHits = ->
    console.log 'init hits'
    exports.scrollSpyPopupLogin('/hits/page/2')
    exports.infiniteScroll('#wrapper .hits', '/hits')

  return exports

