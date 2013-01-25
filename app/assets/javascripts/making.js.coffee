window.Making =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}

  initialize: ->
    $(document).ajaxComplete ->
      $(".spinning").remove()

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

$ ->
  Making.initialize()
