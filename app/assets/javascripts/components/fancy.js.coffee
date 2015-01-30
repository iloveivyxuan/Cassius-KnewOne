$(->
  $('body').append('<div id="fancy-modal-container"></div>')
  region = new Backbone.Marionette.Region({
    el: '#fancy-modal-container'
  })

  popup = (impression, options) ->
    view = new Making.Views.FancyModal({
      model: new Backbone.Model(_.extend(options, impression))
    })
    region.show(view)

  $(document).on('click', '[data-fancy]', (event) ->
    event.preventDefault()

    return if $('#fancy_modal').length

    $target = $(this)
    options = _.pick($target.data(), 'type', 'fancied', 'state')
    options.thing_id = $target.data('fancy')

    if $target.hasClass('unfancied') || $target.hasClass('unowned')
      popup({}, options)
    else
      $.ajax({
        url: "/things/#{options.thing_id}/impression"
        dateType: 'json'
      }).done((impression) ->
        popup(impression, options)
      )
  )
)
