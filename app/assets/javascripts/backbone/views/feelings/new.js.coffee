class Making.Views.FeelingNew extends Backbone.View

  events:
    'input textarea': 'count'
    'submit': 'on_submit'

  initialize: ->
    @photo_view = new Making.Views.PhotosUpload
    @max        = 140
    @$submit    = @$('[type="submit"]')
    @$counter   = @$('.counter')

    @photo_view.render()
    @$submit.disable()

  count: (event) ->
    rest = @max - event.target.value.length
    @$counter.text(rest)
    if rest is @max
      @$submit.disable()
    else if rest > 0
      if @$submit.hasClass('disabled')
        @$submit.enable()
        @$counter.removeClass('error')
    else
      @$submit.disable()
      @$counter.addClass('error')
    return

  on_submit: ->
    @$submit.button('loading')
    $photos = @photo_view.$('.uploaded')

    _.each $photos, (el) =>
      $('<input>').attr(
        name: "feeling[photo_ids][]"
        value: $(el).data('photo-id')
        type: "hidden"
      ).appendTo @$el

    @$el.find('[type="submit"]').disable()
