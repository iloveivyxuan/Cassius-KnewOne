$(->
  $('body').append('<div id="fancy-modal-container"></div>')
  region = new Backbone.Marionette.Region({
    el: '#fancy-modal-container'
  })

  $(document).on('click', '[data-fancy]', (event) ->
    $target = $(this)
    options = $target.data('fancy')

    $.ajax({
      url: "/things/#{options['thing-id']}/impression"
      dateType: 'json'
    }).done((impression) ->
      view = new Making.Views.FancyModal({
        model: new Backbone.Model(_.extend({options}, impression))
      })
      region.show(view)
    )
  )
)
