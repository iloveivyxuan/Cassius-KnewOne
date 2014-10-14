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

class Making.Views.AddToListModal extends Backbone.Marionette.CompositeView
  id: 'add-to-list-modal'
  className: 'modal fade'
  template: HandlebarsTemplates['thing_lists/add_to_list_modal']

  ui: {
    name: 'input[name="name"]'
    description: 'input[name="description"]'
  }

  events: {
    'show.bs.modal': 'reset'
    'hidden.bs.modal': 'destroy'
    'keyup @ui.name': 'editName'
    'submit .new-thing-list-form': 'addThingList'
    'submit .new-thing-list-items-form': 'done'
  }

  collectionEvents: {
    reset: 'initSelected'
    'change:selected': 'addToChangedLists'
  }

  childView: ThingListView
  childViewContainer: 'ul.thing-lists'

  initialize: ->
    @model.set('photo', @model.get('photo').replace(/!huge$/, '!square'))

  onShow: ->
    @$el.modal('show')

  reset: ->
    @collection.fetch({
      reset: true
      success: => @model.get('categories').forEach((name) =>
        @collection.findWhere({name}) || @collection.unshift({name})
      )
    })
    @_changedLists = {}

  initSelected: ->
    thing_id = @model.id
    @collection.each((list) ->
      list.set('selected', _.any(list.get('items'), (x) -> x.thing_id == thing_id), {slient: true})
    )
    @collection.sort()

  editName: (event) ->
    if event.currentTarget.value.trim()
      @$('.new-thing-list-form button').removeClass('disabled')
    else
      @$('.new-thing-list-form button').addClass('disabled')

  addThingList: (event) ->
    event.preventDefault()

    name = @ui.name.val().trim()
    return unless name

    list = @collection.findWhere({name}) || @collection.unshift({name})
    list.set('selected', true)
    @addToChangedLists(list)

    @ui.name.val('')

  done: (event) ->
    event.preventDefault()

    @addThingList(event)

    thing_id = @model.id
    description = @ui.description.val().trim()

    unless _.any(@_changedLists, (l) -> l.get('selected'))
      return @$('form > h5').fadeTo('fast', 0.7).fadeTo('fast', 1)

    @ui.description.val('')

    _.each(@_changedLists, (list) ->
      items = new Backbone.Collection(list.get('items'))
      items.url = "#{list.url()}/items"

      item = items.findWhere({thing_id})

      createItem = -> items.create({thing_id, description})

      if list.isNew()
        if list.get('selected')
          list.save(null, {success: ->
            items.url = "#{list.url()}/items"
            items.create({thing_id, description})
          })
        return

      return item?.destroy() unless list.get('selected')

      if item
        item.save({description}) if description
      else
        createItem()
    )

    @$el.one('hidden.bs.modal', ->
      Making.ShowMessageOnTop('操作成功')
    ) if _.size(@_changedLists)

    @$el.modal('hide')

  addToChangedLists: (list) ->
    @_changedLists[list.cid] = list
