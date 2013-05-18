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
      $(".thing h4").tooltip()
      $(".track_event").click ->
        Making.TrackEvent $(@).data('category'), $(@).data('action'), $(@).data('label')
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

  ReviewEdit: () ->
    $ ->
      Making.Editor $('form.edit_post')
      $el = $('input[type="range"]')
      $el.replaceWith('<div class="rating"></div>')
      Making.Rating $('.rating'), $el.val(), $el.attr('name')

  Editor: (form, content) ->
    $("#editor")
      .wysiwyg
        dragAndDropImages: false
      .html($(content).val())

    $("#editor-toolbar")
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

    $(form)
      .submit ->
        $(content).val($('#editor').html())

  Rating: ($raty, score, name) ->
    $raty.raty
      scoreName: name
      score: score
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
    $modal = $(".share_modal")

    $modal.on "submit form", ->
      $modal.modal("hide")

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
      .after('<aside id="go_top"><i class="icon-circle-arrow-up icon-2x"></i></aside>')
      .infinitescroll
        navSelector: '.pagination'
        nextSelector: '.pagination a[rel="next"]'
        contentSelector: container + ' ul'
        itemSelector: item
        pixelsFromNavToBottom: $('body > footer').height()
        loading:
          msg: $("<div class='loading-things'><i class='icon-spinner icon-spin icon-4x'></i></div>")
        errorCallback: ->
          $(container).find('.loading-things').html("<em>没有更多了......</em>")
    $(window).on 'scroll', ->
      if $(window).scrollTop() > $(window).height()/2
        $('#go_top').fadeIn() if $('#go_top').is(':hidden')
      else
        $('#go_top').fadeOut() if $('#go_top').is(':visible')
       

$ ->
  Making.initialize()
