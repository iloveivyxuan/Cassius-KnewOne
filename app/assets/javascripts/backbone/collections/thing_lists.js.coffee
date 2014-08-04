class Making.Collections.ThingLists extends Backbone.Collection
  url: '/lists'
  model: Making.Models.ThingList

  comparator: (x) -> -new Date(x.get('updated_at')).getTime()

  findOrCreateBy: (attributes) ->
    @findWhere(attributes) || @create(arguments...)
