window.Making = do (exports = window.Making || {}) ->

  $ ->
    $selectpicker = $('select.selectpicker')

    if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenMDMin + ')')
      if $selectpicker.length then $selectpicker.selectpicker()

  # exports
  exports