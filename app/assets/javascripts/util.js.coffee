window.Making = do (exports = window.Making || {}) ->

  exports.GetScrollbarWidth = ->

    inner = document.createElement('p')
    inner.style.width = "100%"
    inner.style.height = "200px"

    outer = document.createElement('div')
    outer.style.position = "absolute"
    outer.style.top = "0px"
    outer.style.left = "0px"
    outer.style.visibility = "hidden"
    outer.style.width = "200px"
    outer.style.height = "150px"
    outer.style.overflow = "hidden"
    outer.appendChild(inner)

    document.body.appendChild(outer)
    w1 = inner.offsetWidth
    outer.style.overflow = 'scroll'
    w2 = inner.offsetWidth
    if w1 is w2 then w2 = outer.clientWidth

    document.body.removeChild(outer)

    return (w1 - w2)
  # from http://stackoverflow.com/questions/901115/how-can-i-get-query-string-values-in-javascript
  exports.GetParameterByKey = (key) ->
    key = key.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]")
    regex = new RegExp("[\\?&]" + key + "=([^&#]*)")
    results = regex.exec(location.search)
    return (if results == null then "" else decodeURIComponent(results[1].replace(/\+/g, " ")))

  #exports
  exports
