window.Making =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  Breakpoints:
    "screenXSMin": "480px"
    "screenXSMax": "767px"
    "screenSMMin": "768px"
    "screenSMMax": "991px"
    "screenMDMin": "992px"
    "screenMDMax": "1439px"
    "screenLGMin": "1440px"
    "screenLGMax": "1919px"
    "screenXLMin": "1920px"

  initialize: ->
    $ ->
      $html = $('html')
      Making.ImageLazyLoading()
      Making.InitUIThings($('.thing'))
      Making.Share()
      $(".popover-toggle").popover()
      $("a.disabled").click ->
        false
      $(".post_content").fitVids()
      $(".track_event").click ->
        Making.TrackEvent $(@).data('category'), $(@).data('action'), $(@).data('label')
      Making.SetupOlark('[href="#olark_chat"]')
      Making.GoTop()
      if $html.hasClass('settings')
        $('#switch_aside').on 'click', ->
          $('#wrapper').addClass 'is_aside_active'
        $('#switch_main').on 'click', ->
          $('#wrapper').removeClass 'is_aside_active'
      $('.entry').on 'click', '.entry_email_toggle', ->
        $form = $(@).parents('.entry').find('.entry_email')
        $form.stop()[if $form.is(':hidden') then 'fadeIn' else 'fadeOut'](160)
        $(@).toggleClass 'active'

      if $html.hasClass 'guest_homepage'
        $('.entry_email_toggle').addClass(if $('.entry_email').is(':visible') then 'active')

      if $('.carousel').length
        Making.ExtendCarousel()
        $(window).on 'resize.bs.carousel.data-api', ->
          if !lock
            lock = true
            Making.ExtendCarousel()
            lock = false
      $('.score').length && Making.Score()
      Making.AjaxComplete()
      Making.ToggleFixedNavbar()
      Making.InitUIDropdownBox()

  ToggleFixedNavbar: ->
    if Modernizr.mq('(max-width: ' + Making.Breakpoints.screenMDMax + ')') and
        $('html').hasClass('touch')
      $element  = $('.navbar-fixed-top')
      $window   = $(window)
      scrollTop = 0
      top       = 0

      $(':input')
        .on 'focusin', ->
          top = $element.css('top')
          $element.css
            'position': 'absolute'
            'top': 0
        .on 'focusout', ->
          $element.css
            'position': 'fixed'
            'top': top

  AjaxComplete: ->
    $(document).ajaxComplete ->
      $(".spinning").remove()

      $things_new = $('.thing').filter -> $(@).attr('target') isnt '_blank'
      Making.InitUIThings($things_new)
      return true

  InitUIThings: ($things) ->
    $things.length and $things.each ->
      $thing = $(@)
      $thing.find('h5').tooltip()

  InitUIDropdownBox: ->
    $dropdown_box = $('.dropdown_box')
    if $dropdown_box.length
      $body = $('body')
      $dropdown_box
        .on 'mouseenter', ->
          if !$body.hasClass('dropdown_box_open')
            $body.addClass('dropdown_box_open')
        .on 'mouseleave', ->
          if $body.hasClass('dropdown_box_open')
            $body.removeClass('dropdown_box_open')

  SetupOlark: (element) ->
    $element    = $(element)
    klass_hint  = $element.data('hint')
    klass_spin  = 'fa-spinner fa-spin'
    $hint       = $element.find('.' + klass_hint)
    initialized = false

    $element.click (e) ->
      e.preventDefault()

      if !initialized
        if $hint.length > 0
          $hint.removeClass(klass_hint).addClass(klass_spin)

        $.getScript $element.data('url'), ->
          $user = $('#user')
          name  = $user.data('name')
          email = $user.data('email')
          id    = $user.data('id')

          olark('api.visitor.updateFullName', {fullName: name}) if name
          olark('api.chat.updateVisitorNickname', {snippet: name }) if name
          olark('api.visitor.updateEmailAddress', {emailAddress: email}) if email
          olark('api.visitor.updateCustomFields', {customerId: id}) if id
          olark('api.box.expand')
          if $hint.length > 0
            olark 'api.box.onExpand', ->
              $hint.removeClass(klass_spin).addClass(klass_hint)

          initialized = true
      else
        olark('api.box.expand')

  GoTop: ->
    $(window).on 'scroll', ->
      if $(window).scrollTop() > $(window).height() / 2
        $('#go_top').fadeIn() if $('#go_top').is(':hidden')
      else
        $('#go_top').fadeOut() if $('#go_top').is(':visible')

    $('#go_top').click (e)->
      e.preventDefault()
      $(@).fadeOut()
      $('html,body').animate {scrollTop: 0}, 'slow'

  TrackEvent: (category, action, label) ->
    try
      _hmt.push ['_trackEvent', category, action, label]
    catch error

  ThingsNew: ->
    $ ->
      view = new Making.Views.ThingsNew
        el: "form.thing_form"

  FormLink: (form, button) ->
    $ ->
      $(button).click ->
        is_sync = $('#check_provider_sync input').prop('checked')
        $("<input name='provider_sync' type='hidden' value=#{is_sync}>").appendTo(form)
        $(form).submit()

  Editor: (textarea, validate = false) ->
    $ ->
      $("#editor")
      .wysiwyg
          dragAndDropImages: false
      .html($(textarea).val())
      .fadeIn()
      .on "drop", (e) ->
          e.stopPropagation()

      $sisyphus = $("#editor-wrapper").sisyphus
        timeout: 5

      $("#editor-toolbar")
      .fadeIn()
      #https://github.com/twitter/bootstrap/issues/5687
      .find('.btn-group > a').tooltip({container: 'body'}).end()
      .find('.dropdown-menu input')
      .click ->
          false
      .change ->
          $(@).parent('.dropdown-menu')
          .siblings('.dropdown-toggle').dropdown('toggle')
      .end()
      .find('input[type="file"]')
      .each ->
          $overlay = $(@)
          $target = $($overlay.data('target'))
          $overlay
          .css('opacity', 0)
          .css('position', 'absolute')
          .attr('title', "插入图像(可以拖拽)")
          .tooltip()
          .offset($target.offset())
          .width($target.outerWidth())
          .height($target.outerHeight())

      $(textarea).closest('form')
        .on 'submit', (e) ->
          $editor = $('#editor')
          if validate and $editor.text().length < 140
            $('<p>')
              .addClass('alert alert-danger')
              .text('内容有点少，建议再详细描述下（至少 140 字）。')
              .insertAfter($editor)
            return false
          else
            $alert = $editor.next('p.alert')
            if $alert.length then $alert.remove()

          resque = $editor.html()
          $(textarea).val resque.replace(/<!--.*?-->/g, '')
          $sisyphus.manuallyReleaseData()

  Voting: () ->
    $form = $('form.not_voted')
    $form.show().find('button').click (e) ->
      $('<input>').attr
        type: "hidden"
        name: "vote"
      .val($(@).data("vote"))
      .appendTo($form)
    .end().on "ajax:success", (e, html, status, xhr) ->
      $form.replaceWith html

  Share: () ->
    share_content_length = ($el) ->
      count = 0.0
      for w in $el.val().replace(/http:\/\/[a-z]+\.[^ \u4e00-\u9fa5]+/g, 'urlurlhereurlurlhere')
        count += (if /[\x00-\xff]/.test(w) then 0.5 else 1.0)
      Math.ceil(count)

    control_modal = ($el) ->
      available_words = 140 - share_content_length($el.find('textarea'))
      if available_words > 0
        $el.find('input[type="submit"]').removeAttr('disabled')
      else
        $el.find('input[type="submit"]').attr('disabled', 'disabled')
      $el.find('.words-check').text("还可以输入#{available_words}字")

    $modal = $(".share_modal")

    $modal.on('propertychange input', 'textarea', -> control_modal($(@).closest('.share_modal')))
    $modal.on('shown', -> control_modal($(@)))
    $modal.on("submit form", -> $modal.modal("hide"))

  Comments: (el) ->
    $ ->
      post_id = $(el).data('postid')
      collection = new Making.Collections.Comments
      collection.url = "/posts/#{post_id}/comments"
      view = new Making.Views.CommentsIndex
        collection: collection
        el: el

  InfiniteScroll: (container, item) ->
    $('.pagination').hide()
    $(container).infinitescroll
      navSelector: '.pagination'
      nextSelector: '.pagination a[rel="next"]'
      contentSelector: container + ' ul.infinite'
      itemSelector: 'ul.infinite > li'
      pixelsFromNavToBottom: 150
      loading:
        msg: $("<div class='loading-things'><i class='fa fa-spinner fa-spin fa-2x'></i></div>")
      errorCallback: ->
        $(container).find('.loading-things').html('<em class="nomore">没有更多了。</em>')
      , (data) ->
        $('.loading-things').remove()
        $(data).find(".lazy").css("visibility", "visible").lazyload
          threshold: 400

  CalculatePrice: ($el) ->
    price = parseFloat($el.children('.price').attr('data-price'))
    quantity = parseFloat($el.children('.item_quantity').val())
    $el.children('.price').text("￥ #{price * quantity}")

  ImageLazyLoading: () ->
    $("img.lazy")
      .filter ->
        $(@).css('visibility') is 'hidden'
      .css('visibility', 'visible')
      .lazyload
        threshold: 0

  Score: ->
    $('.score').each (i, el) ->
      $self = $(el)
      score = $self.data('score')
      $stars = $()
      for val in [5..1]
        $star = $('<span />').addClass('star').data('val', val)
        $star.addClass('active') if $star.data('val') <= parseInt(score)
        $stars = $stars.add($star)

      $('<div />')
        .addClass('rate')
        .data('score', score)
        .append($stars)
        .appendTo($self)

  ExtendCarousel: ->
    $('.carousel').each ->
      $carousel      = $(@)
      $inner         = $carousel.find('.carousel-inner')
      $item          = $inner.children('.item')
      default_height = parseInt($item.css('max-height'))
      height         = _.min([default_height, $inner.width() * 0.75]) + 'px'

      $item.css
        height: height
        lineHeight: height

      if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
        $overview      = $carousel.next('.carousel_overview')
        $overview_body = $overview.children('.slideshow_body')

        if $overview_body.length and $overview_body.is(':visible')
          $prevPage = $overview.find('.left')
          $nextPage = $overview.find('.right')

          $overview_body.sly
            horizontal: 1
            itemNav: 'centered'
            smart: 1
            activateOn: 'click'
            mouseDragging: 1
            touchDragging: 1
            releaseSwing: 1
            speed: 300
            elasticBounds: 1
            dragHandle: 1
            dynamicHandle: 1
            clickBar: 1
            prevPage: $prevPage
            nextPage: $nextPage

          $carousel.on 'slid.bs.carousel', ->
            index = $(@).find('.carousel-inner').children('.item').filter('.active').index()
            $overview.find('.slideshow_inner').children('li').eq(index).addClass('active').siblings().removeClass('active')

$ ->
  Making.initialize()
