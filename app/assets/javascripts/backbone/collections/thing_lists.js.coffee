class Making.Collections.ThingLists extends Backbone.Collection
  url: '/lists'
  model: Making.Models.ThingList

  comparator: (x, y) ->
    dateX = (new Date(x.get('updated_at')) || Date.now()).getTime()
    dateY = (new Date(y.get('updated_at')) || Date.now()).getTime()

    if x.get('selected')
      if y.get('selected')
        if dateX > dateY then -1 else 1
      else
        -1
    else
      if y.get('selected')
        1
      else
        if dateX > dateY then -1 else 1
