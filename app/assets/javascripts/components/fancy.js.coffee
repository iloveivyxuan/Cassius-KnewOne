$(->
  $('body').append('<div id="fancy-modal-container"></div>')
  region = new Backbone.Marionette.Region({
    el: '#fancy-modal-container'
  })

  $(document).on('click', '[data-fancy]', (event) ->
    event.preventDefault()

    return if $('#fancy_modal').length

    $target = $(this)
    options = {
      thing_id: $target.data('fancy')
      type: $target.data('type')
    }

    $.ajax({
      url: "/things/#{options.thing_id}/impression"
      dateType: 'json'
    }).done((impression) ->
      view = new Making.Views.FancyModal({
        model: new Backbone.Model(_.extend(options, impression))
      })
      region.show(view)
    )
  )
)
