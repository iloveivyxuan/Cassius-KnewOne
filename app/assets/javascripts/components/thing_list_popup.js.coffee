$(->
  cache = Object.create({})
  selector = '[data-thing-list-popup]'

  $('body').append('<div id="thing-list-popup-container"></div>')
  region = new Backbone.Marionette.Region({
    el: "#thing-list-popup-container"
  })

  show = (thing) ->
    view = new Making.Views.ThingListsPopup({
      model: new Backbone.Model(thing)
      collection: new Making.Collections.ThingLists()
    })
    region.show(view)

  $(document).on('click', selector, (event) ->
    $target = $(this)
    thingId = $target.data('thing-list-popup')

    return show(cache[thingId]) if cache[thingId]

    $.getJSON("/things/#{thingId}", (thing) ->
      cache[thingId] = thing
      show(thing)
    )
  )
)
