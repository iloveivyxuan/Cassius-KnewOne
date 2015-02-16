do (exports = window.Making || {}) ->

  exports.InitUser = ->
    if $html.is('.users_activities:not(.users_activities_text)') and
      Modernizr.mq('(min-width: ' + exports.Breakpoints.screenSMMin + ')')
        $waterfall = $('.js-waterfall')
        waterfall  = new Masonry $waterfall[0],
          itemSelector: '.activity'

  return exports
