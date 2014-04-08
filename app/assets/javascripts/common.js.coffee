window.Making = do (exports = window.Making || {}) ->
  keycode = exports.keycode

  $ ->
    $textarea     = $('textarea')
    $selectpicker = $('select.selectpicker')

    $(document).on 'keydown', 'textarea', (event) ->
      if (event.metaKey or event.ctrlKey) and event.keyCode is keycode.ENTER
        $(@).parents('form').find('button[type="submit"]').trigger('click')

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
