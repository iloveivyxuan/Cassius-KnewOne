window.Making = do (exports = window.Making || {}) ->
  init_new_thing_modal = (->
    $new_thing_modal = $('#new-thing-modal')
    $new_thing_from_url_modal = $('#new-thing-from-url-modal')

    reset_new_thing_from_url_modal = (->
      $new_thing_from_url_modal
      .find('input').val('').end()
      .find('input, button').attr('disabled', false).end()
      .find('.progress').hide().end()
      .find('.progress-bar').css({width: 0})
    )

    $('#extract_url_form').on('ajax:beforeSend',
    (event, xhr, settings)->
      $new_thing_from_url_modal.find('input, button').attr('disabled', true)
      $new_thing_from_url_modal.find('.progress').show()

      $progress_bar = $new_thing_from_url_modal.find('.progress-bar')
      $progress_bar.animate({width: '100%'}, 3000)
      return
    ).on('ajax:error',
    (event, xhr, settings)->
      reset_new_thing_from_url_modal()
      return
    ).on('ajax:complete',
    (event, xhr, settings)->
      reset_new_thing_from_url_modal()
      return
    )

    $new_thing_from_url_modal.on('show.bs.modal',
    (e)->
      reset_new_thing_from_url_modal()
      $new_thing_from_url_modal.find('.alert').addClass('hidden')
    )
  )

  exports.init_new_thing_modal = (
    ->
      $new_thing_edit_modal = $('#new-thing-edit-modal')

      $('#create_thing_modal_form').on('ajax:beforeSend',
      (event, xhr, settings)->
        $new_thing_edit_modal
        .find('button').attr('disabled', true).end()
        .find('.progress').show()

        $progress_bar = $new_thing_edit_modal.find('.progress-bar')
        $progress_bar.animate({width: '100%'}, 3000)
      )

      $carousel_inner = $('#new-thing-edit-modal-images .carousel-inner')
      $slideshow_inner = $('#new-thing-edit-modal-sortable')

      i = 0
      $.each($('#new-thing-edit-modal-images-container .image .item').find('img'), (index, value)->
        $(value).one('load',
        ->
          $this = $(@)
          height = $this.prop('naturalHeight')
          width = $this.prop('naturalWidth')

          if height >= 300 && width >= 300
            $item = $this.parent()
            $item.find('a')
            .on('click', (event)->
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
            )

            if i == 0
              $carousel_inner.append($item.addClass('active'))
              $item.find('a').click()
            else
              $carousel_inner.append($item)

            $selector = $('#' + $this.attr('data-selector-id')).attr('data-slide-to', i).attr('draggable', true)
            $slideshow_inner.append($selector)
            i += 1

            $("#new-thing-edit-modal-sortable").sortable( "refresh" );
        ).each(
          ->
            if @.complete then $(@).load()
        )
      ).each($('#new-thing-edit-modal-sortable').children(), (index, value)->
        $value = $(value)
        $value.attr('data-slide-to', index)
      )

      $("#new-thing-edit-modal-sortable").sortable();

      $('.select_btn_container > a')
      .on 'click', (event) ->
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
  )

  exports.keycode =
    ENTER: 13

  $ ->
    $user = $('#user')
    $nav_group = $('.nav_group.dropdown')
    $textarea = $('textarea')
    $selectpicker = $('select.selectpicker')
    keycode = exports.keycode

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
    $('.js_auto_submit').on 'change', ->
      $(@).parents('form').trigger('submit')

    if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenMDMin + ')')

      $nav_group.each ->
        $this = $(@)
        $link = $this.children('.nav_group_link')
        url = $link.data('url')
        $dropdown_toggle = $this.children('.nav_group_more')
        $dropdown_menu = $this.children('.dropdown-menu')
        $link
        .attr('href', url)
        .removeClass('dropdown-toggle')
        .removeAttr('data-toggle')
        .removeAttr('data-url')
        $this.on 'mouseleave', ->
          $this.removeClass('open')
        $link.on 'mouseenter', ->
          $this.removeClass('open')
        $dropdown_toggle.on 'mouseenter', (event) ->
          if !$this.hasClass('open') then $this.addClass('open')

      $user.children('.dropdown')
      .on 'mouseenter', ->
        $(@).addClass('open')
      .on 'mouseleave', ->
        $(@).removeClass('open')

      if $selectpicker.length
        $selectpicker.selectpicker()

  init_new_thing_modal()

  # exports
  exports
