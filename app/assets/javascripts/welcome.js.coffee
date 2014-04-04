window.Making = do (exports = window.Making || {}) ->
  _hash = ''

  exports.InitWelcome = ->
    $ ->
      step = location.hash
      if step is '' then step = '#step1'
      $(step).addClass('active')

      $(window).on 'hashchange', ->
        _hash = location.hash
        $(_hash).addClass('active').siblings().removeClass('active')

  #exports
  exports