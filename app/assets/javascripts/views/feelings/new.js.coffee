class Making.Views.FeelingNew extends Backbone.View

  events:
    'keyup textarea': 'count'
    "submit": "collect_photos"

  initialize: ->
    @photo_view = new Making.Views.PhotosUpload
    @photo_view.render()

  count: (event) ->
    $counter = @$el.find('.counter')
    $submit = @$el.find('[type="submit"]')
    rest = 140 - event.target.value.length
    $counter.text(rest)
    if rest <= 0
      $submit.disable()
      $counter.addClass('error')
    else
      if $submit.hasClass('disabled')
        $submit.enable()
        $counter.removeClass('error')

  collect_photos: ->
    $photos = @photo_view.$('.uploaded')

    _.each $photos, (el) =>
      $('<input>').attr(
        name: "feeling[photo_ids][]"
        value: $(el).data('photo-id')
        type: "hidden"
      ).appendTo @$el
