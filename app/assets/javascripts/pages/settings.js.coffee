do (exports = Making) ->

  exports.InitSettings = ->
    $('#switch_aside').on 'click', ->
      $('#wrapper').addClass 'is_aside_active'
    $('#switch_main').on 'click', ->
      $('#wrapper').removeClass 'is_aside_active'
