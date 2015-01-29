$(->
  cache = Object.create(null)
  selector = '[data-add-to-list]'

  $('body').append('<div id="add-to-list-modal-container"></div>')
  region = new Backbone.Marionette.Region({
    el: '#add-to-list-modal-container'
  })

  show = (thing) ->
    view = new Making.Views.AddToListModal({
      model: new Backbone.Model(thing)
      collection: new Making.Collections.ThingLists()
    })
    region.show(view)

  $(document).on('click', selector, (event) ->
    event.preventDefault()

    return if $('#add-to-list-modal').length

    $target = $(this)
    return if $target.is('.fancied')

    thingId = $target.data('thing-id')

    return show(cache[thingId]) if cache[thingId]

    $.getJSON("/things/#{thingId}", (thing) ->
      cache[thingId] = thing
      show(thing)
    )
  )
)
