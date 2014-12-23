do (exports = Making) ->

  init_new_thing_modal = (->
    $new_thing_modal = $('#new-thing-modal')
    $new_thing_from_url_modal = $('#new-thing-from-url-modal')

    $new_thing_from_url_modal.on('click', 'button[type="submit"]', ->
      url = $new_thing_from_url_modal.find('#new-thing-url').val()
      url = "http://#{url}" if url && !/^https?:\/\//.test(url)
      $new_thing_from_url_modal.find('#new-thing-url').val(url)
    )

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

      $('#new-thing-edit-modal').html('')
      $('#new-thing-similar-modal').html('')

      return true
    )

    $new_thing_from_url_modal.on('show.bs.modal',
    (e)->
      reset_new_thing_from_url_modal()
      $new_thing_from_url_modal.find('.alert').addClass('hidden')
    )

    $('#new-thing-url').on('focus',
    (e)->
      $new_thing_from_url_modal.find('.alert').addClass('hidden')
    )
  )

  exports.init_new_thing_modal = (
    ->
      $new_thing_edit_modal = $('#new-thing-edit-modal')
      
      $new_thing_edit_modal.on 'loaded.carousel', ->
        exports.carousel
          element: '#new-thing-edit-modal .carousel'
          isResetItemWidth: true
        $('#new-thing-edit-modal .carousel').css
          maxHeight: 'none'
          visibility: 'visible'

      $('#create_thing_modal_form').on('ajax:beforeSend',
      (event, xhr, settings)->
        $new_thing_edit_modal
        .find('button').attr('disabled', true).end()
        .find('.progress').show()

        $progress_bar = $new_thing_edit_modal.find('.progress-bar')
        $progress_bar.animate({width: '100%'}, 3000)
      ).on 'submit', (event) ->
        $form = $(@)
        $requiredFields = $form.find('[required]')
        $requiredFields.each ->
          $field = $(@)
          if $field.val().trim() is ''
            $field.tooltip('show')

      $carousel_inner = $('#new-thing-edit-modal-images .carousel-inner')
      $slideshow_inner = $('#new-thing-edit-modal-sortable')

      $slideshow_inner.sortable()

      i = 0
      loaded = 0
      flag = true
      $images = $('#new-thing-edit-modal-images-container .image .item').find('img')
      $.each($images, (index, value)->
        $(value).one('load',
        ->
          loaded += 1

          $this = $(@)
          height = $this.prop('naturalHeight')
          width = $this.prop('naturalWidth')

          if height >= 300 || width >= 300
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
              $('#new-thing-edit-modal-images').removeClass('more-than-one')
              $carousel_inner.append($item.addClass('active'))
              $item.find('a').click()
            else
              $('#new-thing-edit-modal-images').addClass('more-than-one')
              $carousel_inner.append($item)

            $selector = $('#' + $this.attr('data-selector-id')).attr('data-slide-to', i).attr('draggable', true)
            $slideshow_inner.append($selector)

            $("#new-thing-edit-modal-sortable").sortable("refresh");

            if $("#new-thing-edit-modal-sortable").children().size() > 0 && flag
              flag = false
              if $('#new-thing-similar-modal').html().length != 0
                $('#new-thing-similar-modal').modal('show')
              else
                $('#new-thing-edit-modal').modal('show')

              $('#new-thing-from-url-modal')
              .find('input').val('').end()
              .find('input, button').attr('disabled', false).end()
              .find('.progress').hide().end()
              .find('.progress-bar').css({width: 0})
            i += 1
          $new_thing_edit_modal.trigger 'loaded.carousel' if loaded is $images.length
        ).each(
          ->
            if @.complete then $(@).load()
        )

        setTimeout(
          ->
            if $("#new-thing-edit-modal-sortable").children().size() == 0
              $('#new-thing-from-url-modal').find('.alert').removeClass('hidden');
              $('#new-thing-from-url-modal')
              .find('input').val('').end()
              .find('input, button').attr('disabled', false).end()
              .find('.progress').hide().end()
              .find('.progress-bar').css({width: 0})
        , 20000
        )
      ).each($('#new-thing-edit-modal-sortable').children(), (index, value)->
        $value = $(value)
        $value.attr('data-slide-to', index)
      )

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

  exports.SetupCustomerServices = (element) ->
    $element   = $(element)
    $modal     = $('#feedback_modal')
    isPageLoaded = false

    $window.on 'load', ->
      isPageLoaded = true

    $element.click (e) ->
      e.preventDefault()
      if typeof mechatClick in ['function', 'object']
        mechatClick()
      else if isPageLoaded
        $modal.modal('show')

  exports.GoTop = ->
    $(window).on 'scroll', ->
      if $(window).scrollTop() > $(window).height() / 2
        $('#go_top').fadeIn() if $('#go_top').is(':hidden')
      else
        $('#go_top').fadeOut() if $('#go_top').is(':visible')

    $('#go_top').click (e)->
      e.preventDefault()
      $(@).fadeOut()
      $('html,body').animate {scrollTop: 0}, 'slow'

  exports.ToggleFixedNavbar = ->
    if $('html').hasClass('touch')
      $element  = $('#header')
      $window   = $(window)
      scrollTop = 0
      top       = 0

      $document
        .on 'focusin', ':input', ->
          top = $element.css('top')
          $element.css
            'position': 'absolute'
            'top': 0
        .on 'focusout', ':input', ->
          $element.css
            'position': 'fixed'
            'top': top

  exports.AjaxComplete = ->
    $(document).ajaxComplete ->
      $(".spinning").remove()

      $things_new = $('.thing').filter -> $(@).attr('target') isnt '_blank'
      Making.InitUIThings($things_new)
      true

  exports.TrackEvent = (category, action, label) ->
    try
      _hmt.push ['_trackEvent', category, action, label]
    catch error

  exports.SaveFormState = ($form) ->
    window.localStorage["saved|#{window.location.pathname}|#{$form.attr('id')}"] = $form.serialize()

  exports.LoadFormState = ($form) ->
    id = $form.attr('id')
    serialized = window.localStorage["saved|#{window.location.pathname}|#{id}"]
    return if serialized == undefined
    $form.deserialize(serialized,
      except: ['authenticity_token']
    )
    delete window.localStorage["saved|#{window.location.pathname}|#{id}"]

  $ ->
    $user = $('#user')
    $navDropdown = $('.navbar .dropdown').not('.notification')
    $textarea = $('textarea')
    $selectpicker = $('select.selectpicker')
    keycode = exports.keycode

    exports.lazyLoadImages()
    exports.InitUIThings($('.thing'))
    exports.Share()
    exports.AjaxComplete()
    exports.ToggleFixedNavbar()
    exports.SetupCustomerServices('[href="#customer_services"]')
    exports.GoTop()
    exports.ProfilePopovers()
    exports.PrivateMessage()
    exports.AtUser('textarea')
    exports.shareOnWechat()

    # TODO
    ($popovertoggle = $(".popover-toggle")).length && $popovertoggle.popover()
    ($score = $('.score')).length && $score.score()
    $('.knewone-embed:empty').length && exports.loadEmbed()
    if $(".track_event").length
      $(".track_event").click ->
        Making.TrackEvent $(@).data('category'), $(@).data('action'), $(@).data('label')
    if ($entry = $('.entry_compact')).length
      $entry.on 'click', '.entry_email_toggle', ->
        $form = $(@).parents('.entry').find('.entry_email')
        $form.stop()[if $form.is(':hidden') then 'fadeIn' else 'fadeOut'](160)
        $(@).toggleClass 'active'

    if exports.user is undefined
      switch exports.device
        when 'mobile', 'tablet'
          $loginButton = $('#header [data-target="#login-modal"]')
        when 'desktop'
          $loginButton = $('#header .user_link[data-target="#login-modal"]')

      $document.on 'click', '.js-require_login', (event) ->
        if $(event.currentTarget).find('textarea').length
          $loginButton.trigger('click')

    $(document)
      .on 'click', 'a.disabled', (event) ->
        false

      .on 'click', '.tags > a', (event) ->
        $tag = $(@)
        if $tag.attr('href') is '#'
          event.preventDefault()
          $tag.toggleClass('is-active')

      .on 'click', '.fanciers > a, .fancy-button > a, .fancy_button > a', (event) ->
        $trigger = $(@)

        if $trigger.data('toggle') is 'modal' then return
        if $trigger.data('toggle') is 'wechat_login' then return

        event.preventDefault()

        if $trigger.find('.fanciers_count').is(':visible')
          $count = $trigger.find('.fanciers_count')
        else if $trigger.parents('.thing').length > 0
          $count = $trigger
            .parents('.thing')
            .find('.figure_detail')
            .find('.fanciers_count')
        else
          $count = $trigger
            .parents('.feed-thing')
            .find('.fanciers-count')

        if $trigger.hasClass('fancied')
          unfancy = ->
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

          key = "#{Making.user}+unfancy-confirmed"
          if !$trigger.data('has-lists') || localStorage.getItem(key)
            unfancy()
          else
            localStorage.setItem(key, true)
            unfancy() if confirm('如果施了“取消喜欢”的神奇魔法，该产品将从列表中消失')
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
      .on 'keyup', 'input', ->
        $trigger = $(@).parents('.search').find('.fa-times')
        if $.trim(@value).length
          $trigger.show()
        else
          $trigger.hide()

    $('.js_auto_submit').on 'change', ->
      $(@).parents('form').trigger('submit')

    $('.entry').on 'click', '[data-toggle="tab"]', (event) ->
      event.preventDefault()
      $this = $(@)
      $pane = $this.parents('.entry').find($this.attr('href'))
      $pane.addClass('active').siblings('.tab-pane').removeClass('active')

    init_new_thing_modal()

    $(document).on 'click', '.share_btn', ->
      $('#share_modal_form')
        .find('textarea[name="share[content]"]').val($(@).attr('data-content')).end()
        .find('input[name="share[pic]"]').val($(@).attr('data-pic')).end()
      if $(@).attr('data-preview-pic')
        $('#share_modal_form')
          .find('.pic_preview')
          .find('img').attr('src', $(@).attr('data-preview-pic')).end()
          .removeClass('hide')

    $('.save_form_state').on 'click', ->
      $.each($('form'),
        (i, v) ->
          exports.SaveFormState($(v))
      )

    $.each($('form'),
      (i, v) ->
        exports.LoadFormState($(v))
    )

    $modal = $('#' + Making.GetParameterByKey('open_modal')).first()
    if $modal.size() != 0
      $modal.modal('toggle')

    # Touch Devices
    # @FIXME #624
    if $html.hasClass('touch')
      $document.on 'touchstart', (event) ->
        console.log 'What happened?'
        return

    # Post content video wrapper
    $('.article > .body, .post_content')
      .find('iframe, embed')
      .filter ->
        $this  = $(@)
        result = true
        src    = $this.attr('src')
        # e.g. <embed src="http://www.xiami.com/widget/0_141236/singlePlayer.swf" type="application/x-shockwave-flash" width="257" height="33" wmode="transparent"></embed>
        if src.indexOf('www.xiami.com') > 0 and src.indexOf('singlePlayer') > 0
          $this.css('width', $this.attr('width'))
          result = false
        return result
      .addClass('embed-responsive-item')
      .wrap('<div class="embed-responsive embed-responsive-16by9"></div>')

    # Screen MD below
    if Modernizr.mq('(max-width: ' + Making.Breakpoints.screenMDMax + ')')
      menu = new exports.View.Menu('#menu', 'body', '#menu_toggle')

    # Screen MD
    if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenMDMin + ')')

      $('#notification_box').children('a').attr('data-toggle', 'dropdown_box')
      new Making.Views.Notification() if Making.user

      $navDropdown.each ->
        $this = $(@)
        $this
          .on 'mouseenter', (event) ->
            $this.addClass('open')
          .on 'mouseleave', (event) ->
            $this.removeClass('open')
        if $this.is('.nav_flyout')
          $this
            .on 'mouseenter', ->
              $docbody.trigger('freeze')
            .on 'mouseleave', ->
              $docbody.trigger('unfreeze')

      $user
        .children('.dropdown')
        .children('.dropdown-toggle')
          .on 'click', ->
            link = $(@).attr('href')
            if link isnt '#'
              window.location.href = link

      $('#new_thing_trigger').attr('data-target', '#new-thing-modal')

      if $selectpicker.length then $selectpicker.selectpicker()
