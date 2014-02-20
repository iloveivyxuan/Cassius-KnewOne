class Making.Views.ThingsNew extends Backbone.View

  events:
    "submit": "collect_photos"
    "focusout #thing_title": "validate_unicity"

  initialize: ->
    @photo_view = new Making.Views.PhotosUpload
    @photo_view.render()

  validate_unicity: (event) ->
    if $('html').hasClass('things_new')
      url     = $('#navbar_search').attr('action') + '.js' # todo
      keyword = $.trim event.target.value
      is_slideshow_initiated = false
      $thing_candidate = $('#thing_candidate')
      $slideshow_body  = $thing_candidate.children('.slideshow_body')
      $close           = $thing_candidate.children('.close')
      $prev_page       = $thing_candidate.find('.slideshow_control.left')
      $next_page       = $thing_candidate.find('.slideshow_control.right')
      $list            = $slideshow_body.find('.slideshow_inner')

      $.ajax
        url: url
        data: q: keyword
        dataType: 'html'
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
      .done (data, status, xhr) ->
        if xhr.status is 200
          is_slideshow_hidden = $thing_candidate.is(':hidden')

          $list.empty().html(data)

          if is_slideshow_hidden then $thing_candidate.css('height', 0).show()
          $slideshow_body.css 'width', ->
            $thing_candidate.width()
          if is_slideshow_hidden then $thing_candidate.css('height', 'auto').hide()

          if !is_slideshow_initiated
            slideshow = new Sly $slideshow_body,
              horizontal: 1
              itemNav: 'centered'
              activateMiddle: 1
              activateOn: 'click'
              mouseDragging: 1
              touchDragging: 1
              releaseSwing: 1
              speed: 300
              elasticBounds: 1
              dragHandle: 1
              dynamicHandle: 1
              clickBar: 1
              prevPage: $prev_page
              nextPage: $next_page
            .init()

            is_slideshow_initiated = true
          else
            slideshow_body.slideTo(0)
            slideshow.reload()

          $thing_candidate.slideDown()

        else
          $close.trigger 'click'

      $close.on 'click', (event) ->
        event.preventDefault()
        $thing_candidate.slideUp()

  validate_photos: ->
    console.log "validate"

  collect_photos: ->
    $photos = @photo_view.$('.uploaded')
    if $photos.length == 0
      $('.fileinput-button').tooltip('show')
      return false

    _.each $photos, (el) =>
      $('<input>').attr(
        name: "thing[photo_ids][]"
        value: $(el).data('photo-id')
        type: "hidden"
      ).appendTo @$el
