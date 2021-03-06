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
      .find('input, button').attr('disabled', false);

      $('#new-thing-url').$progress('remove');
    )

    $('#extract_url_form').on('ajax:beforeSend',
    (event, xhr, settings)->
      $new_thing_from_url_modal.find('input, button').attr('disabled', true);


      $('#new-thing-url').$progress(doneThenRemove: false).$progress('start').on 'done:progress', (e, context) ->
        context.$progress.css(borderRadius: '20px');


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
      $carousel = $('#new-thing-edit-modal-images .carousel')
      $new_thing_edit_modal
        .on 'shown.bs.modal', ->
          exports.carousel
            element: '#new-thing-edit-modal .carousel'
            isResetItemWidth: true
          $carousel.css
            maxHeight: 'none'
            visibility: 'visible'

      $new_thing_edit_modal.off('click', '[data-target="#new-thing-edit-modal-images .carousel"]')
      $new_thing_edit_modal.on 'click', '[data-target="#new-thing-edit-modal-images .carousel"]', (e) ->

        e.preventDefault()
        $this = $(this)
        $input = $this.find('input')
        if $this.hasClass('selected')
          $this.removeClass('selected')
          $input.attr('disabled', 'disabled')
        else
          $this.addClass('selected')
          $input.removeAttr('disabled')

        carousel = $('#new-thing-edit-modal-images .carousel').data('carousel')
        carousel.slickGoTo $(this).attr('data-slide-to')


      $('#create_thing_modal_form').on('ajax:beforeSend',
      (event, xhr, settings)->
        $new_thing_edit_modal.find('.btn-primary').$progress
          withText: false
          doneThenRemove: false
          initFn: ->
            @$progress.css(borderRadius: '12px')
            @$wrapper.css(marginLeft: '1em')
        .$progress('start')

      ).on 'submit', (event) ->
        $form = $(@)
        $requiredFields = $form.find('[required]')
        $requiredFields.each ->
          $field = $(@)
          if $field.val().trim() is ''
            $field.tooltip('show')


      $new_thing_edit_modal.find('textarea').$contentCount()


      $carousel_inner = $('#new-thing-edit-modal-images .carousel-inner')
      $slideshow_inner = $('#new-thing-edit-modal-sortable')

      $slideshow_inner.sortable()

      resize = do ->
        winWidth = $(window).width()
        size = if winWidth > 768
          600 / 5
        else
          (winWidth - 20) / 3

        ($selector, height, width) ->
          $img = $selector.find('img')

          [imgW, imgH] = if width > height
            [size / height * width, size]
          else if width < height
            [size, size / width * height]
          else
            [size, size]

          $selector.css(height: size)
          $img.css(height: imgH, width: imgW)


      i = 0
      loaded = 0
      flag = true
      $images = $('#new-thing-edit-modal-images-container .image .item').find('img')
      carousel = undefined

      $.each($images, (index, value)->
        $(value).one('load',
        ->
          loaded += 1

          $this = $(@)
          height = $this.prop('naturalHeight')
          width = $this.prop('naturalWidth')

          if height >= 300 || width >= 300
            $item = $this.parent()
            $('#new-thing-edit-modal-images').addClass('more-than-one')

            if carousel ||= $carousel.data('carousel')
              carousel.slickAdd($item[0])
            else
              $carousel_inner.append($item)

            $selector = $('#' + $this.attr('data-selector-id')).attr('data-slide-to', i).attr('draggable', true)
            $slideshow_inner.append($selector)
            setTimeout ->
              resize($selector, height, width)
            , 0

            $("#new-thing-edit-modal-sortable").sortable("refresh");

            if $("#new-thing-edit-modal-sortable").children().size() > 0 && flag
              flag = false
              if $('#new-thing-similar-modal').html().length != 0
                $('#new-thing-similar-modal').modal('show')
              else
                $('#new-thing-edit-modal').modal('show')

              $('#new-thing-from-url-modal')
              .find('input').val('').end()
              .find('input, button').attr('disabled', false)

              $('#new-thing-url').$progress('remove')
            i += 1
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
              .find('input, button').attr('disabled', false)

              $('#new-thing-url').$progress('remove');
        , 20000
        )
      ).each($('#new-thing-edit-modal-sortable').children(), (index, value)->
        $value = $(value)
        $value.attr('data-slide-to', index)
      )
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

  exports.analytics = ->
    $document.on 'click', '[data-action]', (event) ->
      $element = $(event.currentTarget)
      category = $element.attr('data-category')
      action   = $element.attr('data-action')
      label    = $element.attr('data-label')
      ga('send', 'event', category, action, label)

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
    exports.analytics() if $('html').hasClass("production")

    # TODO
    ($popovertoggle = $(".popover-toggle")).length && $popovertoggle.popover()
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

      .on 'keydown', 'textarea', (event) ->
        if (event.metaKey or event.ctrlKey) and event.keyCode is keycode.ENTER
          $(@).parents('form').find('button[type="submit"]').trigger('click')

    $('.form-group.search')
      .on 'click', '.fa-times', ->
        $(@).hide().parents('.search').find('input').val('')
      .on 'keyup focus', 'input', ->
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

    # Mobile and Tablet
    if $html.hasClass('mobile') or $html.hasClass('tablet')
      menu = new exports.View.Menu('.menu', 'body', '.menu-toggle')

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
