class ThingListView extends Backbone.Marionette.ItemView
  tagName: 'li'
  className: 'thing-list'
  template: HandlebarsTemplates['thing_lists/list']

  events: {
    'change input': 'toggle'
  }

  modelEvents: {
    change: 'render'
  }

  toggle: (event) ->
    @model.set('selected', event.currentTarget.checked)

class Making.Views.ThingListsPopup extends Backbone.Marionette.CompositeView
  className: 'thing-list-popup modal fade'
  template: HandlebarsTemplates['thing_lists/popup']

  ui: {
    name: 'input[name="name"]'
    description: 'input[name="description"]'
  }

  events: {
    'show.bs.modal': 'reset'
    'hide.bs.modal': 'destroy'
    'submit .new-thing-list-form': 'addThingList'
    'submit .new-thing-list-items-form': 'done'
  }

  collectionEvents: {
    reset: 'initSelected'
    'change:selected': 'toggleSelected'
  }

  childView: ThingListView
  childViewContainer: 'ul.thing-lists'

  onShow: ->
    @$el.modal('show')

  reset: ->
    @collection.fetch({reset: true})
    @_changedLists = {}

  initSelected: ->
    thing_id = @model.id
    @collection.each((list) ->
      list.set('selected', _.any(list.get('items'), (x) -> x.thing_id == thing_id))
    )

  addThingList: (event) ->
    event.preventDefault()

    name = @ui.name.val().trim()
    return unless name

    list = @collection.findOrCreateBy({name}, {wait: true})
    if list.isNew()
      @listenToOnce(@collection, 'sync', (list) -> list.set('selected', true))
    else
      list.set('selected', true)

    @ui.name.val('')

  done: (event) ->
    event.preventDefault()

    thing_id = @model.id
    description = @ui.description.val().trim()
    @ui.description.val('')

    _.each(@_changedLists, (list) ->
      items = new Backbone.Collection(list.get('items'))
      items.url = "#{list.url()}/items"

      item = items.findWhere({thing_id})

      return item?.destroy() unless list.get('selected')

      if item
        item.save({description}) if description
      else
        items.create({thing_id, description})
    )

    @$el.modal('hide')

  toggleSelected: (list) ->
    @_changedLists[list.cid] = list
