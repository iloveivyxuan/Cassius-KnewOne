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
      Making.GoTop()
      Making.Ticket()

  GoTop: ->
    $(window).on 'scroll', ->
      if $(window).scrollTop() > $(window).height()/2
        $('#go_top').fadeIn() if $('#go_top').is(':hidden')
      else
        $('#go_top').fadeOut() if $('#go_top').is(':visible')
    
    $('#go_top').click ->
      $(@).fadeOut()
      $('html,body').animate {scrollTop: 0}, 'slow'

  Ticket: ->
    $ ->
      $ticket = $('#ticket')
      body_height = $ticket.height() - $ticket.find('.ticket-header').height()

      $ticket.css('bottom', -body_height)

      $ticket.find('.show').click ->
        $ticket.find('.ticket-body').scrollTop($ticket.find('.ticket-body')[0].scrollHeight)
        $ticket.animate({bottom: 0})
        $(@).hide()
        $ticket.find('.hide').show()
      $ticket.find('.hide').click ->
        $ticket.animate({bottom: -body_height})
        $(@).hide()
        $ticket.find('.show').show()

      $ticket.find('textarea').keypress ->
        if event.ctrlKey && event.keyCode == 13
          if $(@).val().replace('/[\s\r\n]/g', '') != ""
            $(@).val('')
          false

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
