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

  ThingsIndex: ->
    $ ->
      collection = new Making.Collections.Things
      view = new Making.Views.ThingsIndex(collection: collection)
      $('#things').html(view.render().el)

  ThingsNew: ->
    $ ->
      view = new Making.Views.ThingsNew
        el: "form.thing_form"

  ThingSummary: ->
    $ ->
      view = new Making.Views.ThingSummary
        el: "#thing_summary"

  ReviewEdit: () ->
    $ ->
      Making.Editor $('form.edit_review')
      $el = $('input[type="range"]')
      $el.replaceWith('<div class="rating"></div>')
      Making.Rating $('.rating'), $el.val(), $el.attr('name')

  ReviewShow: () ->
    $ ->
      #$('#review_content img').closest('p').css('text-align', 'center') 
    
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

$ ->
  Making.initialize()
