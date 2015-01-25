class Making.Views.FancyModal extends Backbone.Marionette.ItemView
  id: 'fancy_modal'
  className: 'modal fade'
  template: HandlebarsTemplates['fancy/modal']

  ui: {
  }

  events: {
  }

  modelEvents: {
    change: 'render'
  }

  initialize: ->
    @initTags()

  initTags: ->
    tagNames = @model.get('tags')
    tags = tagNames.map((name) -> {name, selected: true})
    recent_tags = @model.get('recent_tags').map((name) ->
      {name, selected: _.indexOf(tagNames, name) != -1}
    )
    popular_tags = @model.get('popular_tags').map((name) ->
      {name, selected: _.indexOf(tagNames, name) != -1}
    )

    @model.set({tags, recent_tags, popular_tags})

  onShow: ->
    @$el.modal('show')

  onRender: ->
    @$el.find('[name="score"]').rating()
