window.Making = do (exports = window.Making || {}) ->

  exports.keycode =
    ENTER: 13

  $ ->
    $nav_group    = $('.nav_group.dropdown')
    $textarea     = $('textarea')
    $selectpicker = $('select.selectpicker')
    keycode       = exports.keycode

    $(document)
      .on 'click', '.fanciers > a', (event) ->
        event.preventDefault()

        $trigger = $(@)

        if $trigger.data('toggle') is 'modal' then return

        if $trigger.find('.fanciers_count').is(':visible')
          $count = $trigger.find('.fanciers_count')
        else
          $count = $trigger
                    .parents('.thing')
                      .find('.figure_detail')
                        .find('.fanciers_count')

        if $trigger.hasClass('fancied')
          $trigger
            .removeClass('fancied')
            .addClass('unfancied')
            .attr('title', '取消喜欢')
              .children('.fa')
                .removeClass('fa-heart')
                .addClass('fa-heart-o heartbeat')
                # TODO change transitionEnd event to animationend event
                .one $.support.transition.end, ->
                  $(@).removeClass('heartbeat')
                .emulateTransitionEnd(750)
          if $count.length then $count.text(parseInt($count.text(), 10) - 1)

        else
          $trigger
            .removeClass('unfancied')
            .addClass('fancied')
            .attr('title', '喜欢')
              .children('.fa')
                .removeClass('fa-heart-o')
                .addClass('fa-heart heartbeat')
                # TODO change transitionEnd event to animationend event
                .one $.support.transition.end, ->
                  $(@).removeClass('heartbeat')
                .emulateTransitionEnd(750)
          if $count.length then $count.text(parseInt($count.text(), 10) + 1)

        $.ajax
          url: $trigger.data('url')
          type: 'post'

        return

      .on 'keydown', 'textarea', (event) ->
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

      $nav_group.each ->
        $nav = $(@).children('a').first()
        url  = $nav.data('url')
        $nav
          .attr('href', url)
          .removeClass('dropdown-toggle')
          .removeAttr('data-toggle')
          .removeAttr('data-url')

      if $selectpicker.length then $selectpicker.selectpicker()

  # exports
  exports
