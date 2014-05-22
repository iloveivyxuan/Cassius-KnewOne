do (exports = Making) ->

  # TODO
  exports.Breakpoints =
    "screenXSMin": "480px"
    "screenXSMax": "767px"
    "screenSMMin": "768px"
    "screenSMMax": "991px"
    "screenMDMin": "992px"
    "screenMDMax": "1439px"
    "screenLGMin": "1440px"
    "screenLGMax": "1919px"
    "screenXLMin": "1920px"

  exports.keycode =
    ENTER: 13

  if $html.hasClass('mobile')
    exports.device = 'mobile'
  else if $html.hasClass('tablet')
    exports.device = 'tablet'
  else if $html.hasClass('desktop')
    exports.device = 'desktop'
