class Making.Collections.ThingLists extends Backbone.Collection
  url: '/lists'
  model: Making.Models.ThingList

  comparator: (x) ->
    [(if x.get('selected') then 0 else 1), x.get('name')]
