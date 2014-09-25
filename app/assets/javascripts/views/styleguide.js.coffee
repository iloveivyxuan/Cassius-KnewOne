do (exports = Making, $ = jQuery) ->

  exports.InitStyleguide = ->
    hljs.configure
      tabReplace: '  '

    hljs.initHighlightingOnLoad()

  return exports
