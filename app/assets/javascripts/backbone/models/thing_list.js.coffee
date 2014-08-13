class Making.Models.ThingList extends Backbone.Model
  defaults: {
    items: []
    selected: false
  }

  lengthWithSelected: -> @get('items').length + Number(@get('selected'))

  toJSON: -> _.extend({length: @lengthWithSelected()}, super())
