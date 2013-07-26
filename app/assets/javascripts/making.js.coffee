window.Making =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  initialize: ->
    $ ->
      $(document).ajaxComplete ->
        $(".spinning").remove()
      Making.Score()
      Making.Share()
      $(".popover-toggle").popover()
      $("a.disabled").click -> 
        false
      $(".thing h4").tooltip()
      $(".post_content").fitVids()
      $(".track_event").click ->
        Making.TrackEvent $(@).data('category'), $(@).data('action'), $(@).data('label')
      $('.olark_chat').click ->
        olark('api.box.expand')
      Making.GoTop()

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

  Rating: (form) ->
    $ ->
      $el = $(form).find('input[type="range"]')
      $el.replaceWith('<div class="rating"></div>')
      $('.rating').raty
        scoreName: $el.attr('name')
        score: $el.val()
        path: '/assets/'

  Score: ->
    $('.score').each (i, el) ->
      $(el).raty
        score: $(el).data('score')
        readOnly: true
        path: '/assets'

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
    $(container)
    .infinitescroll
        navSelector: '.pagination'
        nextSelector: '.pagination a[rel="next"]'
        contentSelector: container + ' ul'
        itemSelector: item
        pixelsFromNavToBottom: 150
        loading:
          msg: $("<div class='loading-things'><i class='icon-spinner icon-spin icon-4x'></i></div>")
        errorCallback: ->
          $(container).find('.loading-things').html("<em>没有更多了......</em>")


$ ->
  Making.initialize()
