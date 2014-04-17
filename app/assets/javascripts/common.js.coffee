window.Making = do (exports = window.Making || {}) ->
  init_new_thing_modal = (->
    $new_thing_modal          = $('#new-thing-modal')
    $new_thing_from_url_modal = $('#new-thing-from-url-modal')
    $new_thing_similar_modal  = $('#new-thing-similar-modal')
    $new_thing_edit_modal     = $('#new-thing-edit-modal')

    reset_new_thing_from_url_modal = (->
      $new_thing_from_url_modal.find('input').val('')
      $new_thing_from_url_modal.find('input, button').attr('disabled', false)
      $new_thing_from_url_modal.find('.progress').hide()
      $new_thing_from_url_modal.find('.progress-bar').css({width: 0})
      $new_thing_from_url_modal.find('.alert').remove()
    )

    $new_thing_from_url_modal.on('show.bs.modal', reset_new_thing_from_url_modal)

    reset_new_thing_edit_modal = (->
      $new_thing_from_url_modal.find('#thing_subtitle').val('')
      $new_thing_from_url_modal.find('#thing_content').val('')
    )

    $new_thing_edit_modal.on('show.bs.modal', reset_new_thing_edit_modal)

    $new_thing_from_url_modal.on('click', '.btn-primary', (event) ->
      event.preventDefault()

      $new_thing_from_url_modal.find('input, button').attr('disabled', true)
      $new_thing_from_url_modal.find('.progress').show()

      $progress_bar = $new_thing_from_url_modal.find('.progress-bar')
      $progress_bar.animate({width: '100%'}, 3000)

      url = $('#new-thing-url').val()

      onFailure = (->
        reset_new_thing_from_url_modal()

        html = HandlebarsTemplates['shared/alert']({
          level: 'danger'
          content: '抓取失败，请确认地址无误后重试'
        })
        $new_thing_from_url_modal.find('.modal-body').append(html)
      )

      onSuccess = ((new_thing) ->
        $.get('/api/v1/find_similar', {keyword: new_thing.title})
        .fail(onFailure)
        .done((similar_thing) ->
          $new_thing_edit_modal.find('img').attr('src', new_thing.images[0])
          $new_thing_edit_modal.find('#thing_images').val(new_thing.images[0])
          $new_thing_edit_modal.find('#thing_title').val(new_thing.title)

          if similar_thing
            $new_thing_similar_modal.find('a').attr('href', similar_thing.url)
            $new_thing_similar_modal.find('img').attr('src', similar_thing.cover_url)
            $new_thing_similar_modal.find('figcaption').text(similar_thing.title)

          $progress_bar.animate({width: '100%'}, 100)

          setTimeout(->
            $new_thing_from_url_modal.modal('hide')

            $prev = $new_thing_edit_modal.find('.prev')

            if similar_thing
              $prev.attr('data-target', '#new-thing-similar-modal')
              $new_thing_similar_modal.modal('show')
            else
              $prev.attr('data-target', '#new-thing-from-url-modal')
              $new_thing_edit_modal.modal('show')
          , 1000)
        )
      )

      $.get('/api/v1/extract_url', {url})
      .done(onSuccess)
      .fail(onFailure)

      # setTimeout(->
      #   onSuccess({
      #     title: 'LAMY dialog3 焦点系列伸缩钢笔'
      #     images: ['http://image.knewone.com/photos/cbe692f85126b1d63c8fde996209459d.jpg']
      #   })
      # , 100)
    )
  )

  exports.keycode =
    ENTER: 13

  $ ->
    $user         = $('#user')
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
        $this            = $(@)
        $link            = $this.children('.nav_group_link')
        url              = $link.data('url')
        $dropdown_toggle = $this.children('.nav_group_more')
        $dropdown_menu   = $this.children('.dropdown-menu')
        $link
          .attr('href', url)
          .removeClass('dropdown-toggle')
          .removeAttr('data-toggle')
          .removeAttr('data-url')
        $this.on 'mouseleave', -> $this.removeClass('open')
        $link.on 'mouseenter', -> $this.removeClass('open')
        $dropdown_toggle.on 'mouseenter', (event) ->
          if !$this.hasClass('open') then $this.addClass('open')

      $user.children('.dropdown')
        .on 'mouseenter', -> $(@).addClass('open')
        .on 'mouseleave', -> $(@).removeClass('open')

      if $selectpicker.length then $selectpicker.selectpicker()

  init_new_thing_modal()

  # exports
  exports
