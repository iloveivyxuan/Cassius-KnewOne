window.Making = do (exports = window.Making || {}) ->

  $ ->
    $selectpicker = $('select.selectpicker')

    $('.form-group.search')
      .on 'click', '.fa-times', ->
        $(@).hide().parents('.search').find('input').val('')
      .on 'keyup', 'input',  ->
        if $.trim(@.value) isnt ''
          $trigger = $(@).parents('.search').find('.fa-times')
          if $trigger.is(':hidden') then $trigger.show()

    if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenMDMin + ')')
      if $selectpicker.length then $selectpicker.selectpicker()

  # exports
  exports