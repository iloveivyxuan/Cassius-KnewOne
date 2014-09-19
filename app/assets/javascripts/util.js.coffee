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

  exports.ReadMore = (content) ->
    _$content = $(content)
    _$more    = _$content.next('.more')
    _summary_height = parseInt(_$content.css('maxHeight')) - 1

    if _$content.height() < _summary_height
      _$content
        .removeClass('is_folded')
        .next('.more')
          .remove()

    _$more.on 'click', (event) ->
      event.preventDefault()

      $(@)
        .toggleClass('shown')
        .prev('.post_content')
          .toggleClass('is_folded')

  # converts special characters (like <) into their escaped/encoded values (like &lt;).
  # This allows you to show to display the string without the browser reading it as HTML.
  exports.htmlEntities = (str) ->
    return String(str)
              .replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;')

  #exports
  exports
