window.Making = do (exports = window.Making || {}) ->

  exports.InitSandbox = ->
    $("#sortable").sortable();

    $(document)
    .on 'click', '.select_btn_container > a', (event) ->
      event.preventDefault()

      $trigger = $(@)

      $selector = $('#' + $trigger.attr('data-selector-id'))
      $input = $selector.children('input')
      $flag = $selector.children('.selected_icon')

      if $input.attr('disabled') == 'disabled'
        $input.removeAttr('disabled')
        $flag.removeClass('hidden')
      else
        $input.attr('disabled', 'disabled')
        $flag.addClass('hidden')

      if $trigger.data('toggle') is 'modal' then return

      if $trigger.hasClass('selected')
        $trigger
        .removeClass('selected')
        .addClass('unselect')
        .attr('title', '取消选择')
        .children('.fa')
        .removeClass('fa-circle')
        .addClass('fa-circle-o heartbeat')
        .one $.support.transition.end, ->
          $(@).removeClass('heartbeat')
        .emulateTransitionEnd(750)
      else
        $trigger
        .removeClass('unselect')
        .addClass('selected')
        .attr('title', '选择')
        .children('.fa')
        .removeClass('fa-circle-o')
        .addClass('fa-check-circle-o heartbeat')
        .one $.support.transition.end, ->
          $(@).removeClass('heartbeat')
        .emulateTransitionEnd(750)
      return

  #exports
  exports
