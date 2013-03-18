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

  Analystics: () ->
    _bdhmProtocol = (("https:" == document.location.protocol) ? " https://" : " http://")
    $ ->
      $('<script></script>')
        .attr('src', _bdhmProtocol+"hm.baidu.com/h.js%3Fb44696b80ba45a90a23982e53f8347d0")
        .appendTo('body')
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

  ThingShow: ->
    $ ->
      Making.Fancy()
      Making.Own()
      Making.Sharing()
      Making.Shopping()

  ReviewEdit: () ->
    $ ->
      Making.Editor $('form.edit_review')
      $el = $('input[type="range"]')
      $el.replaceWith('<div class="rating"></div>')
      Making.Rating $('.rating'), $el.val(), $el.attr('name')

  ReviewShow: () ->
    $ ->
      Making.Voting()
      Making.Sharing()
      Making.Fancy()
      Making.Own()
      Making.Shopping()
    
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

  Fancy: () ->
    $('.fancy').on "ajax:success", (e, html, status, xhr) ->
      $(@).find('button').replaceWith html
    $('.fancy .unfancy').hover (e) ->
      $(this).find('span').text "取消喜欢"
    , (e) ->
      $(this).find('span').text "已喜欢"

  Own: () ->
    $('.own').on "ajax:success", (e, html, status, xhr) ->
      $(@).find('button').replaceWith html

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

  Sharing: () ->
    $share = $(".share_modal")

    $share.on "submit form", ->
      $share.modal("hide")
      $(".share button").addClass("active")

    $share.find(".share_cancel").click (e) ->
      e.preventDefault()
      $share.modal("hide")
    .end().find(".share_submit").click (e) ->
      $share.find("form").submit()

    $(".share button").click (e) ->
      e.preventDefault()
      $share.modal()

  Shopping: () ->
    $shop = $(".thing_shop")
    if $shop.find("button").hasClass("disabled")
      $shop.popover()
      $shop.click (e) ->
        e.preventDefault()

  Comments: (el) ->
    $ ->
      post_id = $(el).data('postid')
      collection = new Making.Collections.Comments
      collection.url = "/posts/#{post_id}/comments"
      view = new Making.Views.CommentsIndex
        collection: collection
        el: el

$ ->
  Making.initialize()
