window.Making =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  Breakpoint: {
    "screenXSMin": "480px"
    "screenSMMin": "768px"
    "screenMDMin": "992px"
    "screenLGMin": "1440px"
    "screenXLMin": "1920px"
    "screenXSMax": "767px"
    "screenSMMax": "991px"
    "screenMDMax": "1439px"
    "screenLGMax": "1919px"
  }

  initialize: ->
    $ ->
      Making.ImageLazyLoading()
      $(document).ajaxComplete ->
        $(".spinning").remove()
      Making.Share()
      $(".popover-toggle").popover()
      $("a.disabled").click ->
        false
      $(".thing h4").tooltip()
      $(".post_content").fitVids()
      $(".track_event").click ->
        Making.TrackEvent $(@).data('category'), $(@).data('action'), $(@).data('label')
      $('a[href="#olark_chat"]').click ->
        olark('api.box.expand')
      Making.GoTop()
      $('#switch_aside').on 'click', ->
        $('.offcanvas_mix').addClass 'is_aside_active'
      $('#switch_main').on 'click', ->
        $('.offcanvas_mix').removeClass 'is_aside_active'
      $('.entry').on 'click', '.entry_email_toggle', ->
        $form = $(@).parents('.entry').find('.entry_email')
        $form.stop()[if $form.is(':hidden') then 'fadeIn' else 'fadeOut'](160)
        $(@).toggleClass 'active'
      $('html.home_landing .feature_pager').on 'click', (e) ->
        e.preventDefault()
        scrollTop = $('#home_index').offset().top;
        $('html, body').animate {
          scrollTop: scrollTop
        }, 'normal'
        return
      if $('html').hasClass 'home_landing'
        $comments = $('.feature_comment')
        length = $comments.length
        if length > 1
          times = length - 1
          i = 1
          setInterval ->
            $comments
              .filter(':visible')
              .css('position', 'absolute')
              .hide()
            .end()
              .eq(i)
              .css('position', 'static')
              .fadeIn()
            i = if i < times then ++i else 0
          , 5000
      if $('.carousel').length
        Making.ExtendCarousel()
        $(window).on 'resize.bs.carousel.data-api', -> Making.ExtendCarousel()
      $('[type="range"].range_rating').length && Making.Rating()
      $('.score').length && Making.Score()

  OlarkSetUser: (name, email, id) ->
    olark('api.visitor.updateFullName', {fullName: name}) if name
    olark('api.chat.updateVisitorNickname', {snippet: name }) if name
    olark('api.visitor.updateEmailAddress', {emailAddress: email}) if email
    olark('api.visitor.updateCustomFields', {customerId: id}) if id

  GoTop: ->
    $(window).on 'scroll', ->
      if $(window).scrollTop() > $(window).height() / 2
        $('#go_top').fadeIn() if $('#go_top').is(':hidden')
      else
        $('#go_top').fadeOut() if $('#go_top').is(':visible')

    $('#go_top').click ->
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

  Editor: (textarea) ->
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
      .submit (e) ->
          resque = $('#editor').html()
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
      contentSelector: container + ' ul'
      itemSelector: item
      pixelsFromNavToBottom: 150
      loading:
        msg: $("<div class='loading-things'><i class='fa fa-spinner fa-spin fa-2x'></i></div>")
        finished: ->
          $('.loading-things').fadeOut 200
      errorCallback: ->
        $(container).find('.loading-things').html("<em>没有更多了......</em>")

  CalculatePrice: ($el) ->
    price = parseFloat($el.children('.price').attr('data-price'))
    quantity = parseFloat($el.children('.item_quantity').val())
    $el.children('.price').text("￥ #{price * quantity}")

  ImageLazyLoading: () ->
    $(document).ajaxComplete ->
      $("img.lazy").css("visibility", "visible").lazyload()
    $("img.lazy").css("visibility", "visible").lazyload()

  Rating: ->
    $('[type="range"].range_rating').each ->
      $range = $(@)
      $stars = $()
      for val in [parseInt($range.attr('max'))..1]
        $stars = $stars.add($('<span />').addClass('star').data('val', val))
      $rating = $('<div />')
                  .addClass('rating')
                  .append($stars)
                  .insertAfter($range)
                  .data('score', $range.val())
                  .on 'click', '.star', ->
                    $star = $(@)
                    $star.addClass('selected')
                      .siblings().removeClass('selected')
                    $range.val($star.data('val'))
                    $star.parents('.rating').data('score', $range.val())
      $rating.find('.star').eq(-parseInt($range.val())).addClass('selected')

  Score: ->
    $('.score').each (i, el) ->
      $self = $(el)
      score = $self.data('score')
      $stars = $()
      for val in [5..1]
        $star = $('<span />').addClass('star').data('val', val)
        $star.addClass('active') if $star.data('val') <= parseInt(score)
        $stars = $stars.add($star)

      $rating = $('<div />')
                  .addClass('rate')
                  .data('score', score)
                  .append($stars)
                  .appendTo($self)

  ExtendCarousel: ->
    if Modernizr.mq('(min-width: ' + Making.Breakpoint.screenSMMin + ')')
      $('.carousel').each ->
        $carousel = $(@)
        $item = $carousel.children('.carousel-inner').children('.item')
        $image = $item.children('img')
        $overview = $carousel.next('.carousel-overview')
        defaultHeight = parseInt($image.css('max-height'))

        imageHeightArray = _.map $image, ($i) ->
          console.log $i.height
          $i.height

        height = if _.max(imageHeightArray) > defaultHeight then defaultHeight else _.max(imageHeightArray)
        console.log height, defaultHeight, _.max(imageHeightArray)
        height = 480 if height is 0

        $item.css({
          height: height + 'px'
          lineHeight: height + 'px'
        })

        if $overview.length and $overview.is(':visible')
          $prevPage = $overview.find('.prev-page')
          $nextPage = $overview.find('.next-page')
          $overview.sly({
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
          })

          $carousel.on 'slid.bs.carousel', ->
            index = $(@).find('.carousel-inner').children('.item').filter('.active').index()
            $overview.find('.carousel-thumb').children('li').eq(index).addClass('active').siblings().removeClass('active')
    else
      $('.carousel-inner').children('.item').css({
        height: 'auto'
        lineHeight: -> $('body').css('lineHeight')
      })

$ ->
  Making.initialize()
