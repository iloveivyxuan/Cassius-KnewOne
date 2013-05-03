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
      $(".track_event").click ->
        Making.TrackEvent $(@).data('category'), $(@).data('action'), $(@).data('label')

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

  Editor: ($form) ->
    csrf_token = $('meta[name=csrf-token]').attr('content');
    csrf_param = $('meta[name=csrf-param]').attr('content');
    params = ""
    if csrf_param && csrf_token
      params = csrf_param + "=" + encodeURIComponent(csrf_token);
    $form.find('textarea').redactor
      imageUpload: "/review_photos?" + params
      fixed: true
      minHeight: 400
      lang: 'zh_cn'

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
    $(container).infinitescroll
      debug: true
      navSelector: '.pagination'
      nextSelector: '.pagination a[rel="next"]'
      contentSelector: container + ' ul'
      itemSelector: item
      animate: true
      loading:
        msg: $("<div class='loading'><i class='icon-spinner icon-spin icon-2x'></i></div>")
      errorCallback: ->
        $(container).find('.loading').html("<em>No more......</em>")
       

$ ->
  Making.initialize()
