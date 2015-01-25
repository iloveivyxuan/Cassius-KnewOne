class Making.Views.FancyModal extends Backbone.Marionette.ItemView
  id: 'fancy_modal'
  className: 'modal fade'
  template: HandlebarsTemplates['fancy/modal']

  ui: {
    tagsForm: '.fancy_modal-tags_form'
    tagsInput: '[name="tag_names"]'
  }

  events: {
    'submit @ui.tagsForm': 'onTagsFormSubmit'
  }

  modelEvents: {
    change: 'render'
  }

  initialize: ->
    @initModel()
    @tryToUpdateTriggerState(1)

  tryToUpdateTriggerState: (increment) ->
    {type, $trigger} = @model.attributes

    if type == 'fancy'
      $count = $trigger.find('.fanciers_count')
    else
      $count = $trigger.find('.owners_count')

    updateFanciersCount = ->
      $humanizedNumber = $count.find('.humanized_number')
      if $humanizedNumber.length
        $humanizedNumber.attr('title', parseInt($humanizedNumber.attr('title')) + increment)
      else
        $count.text(parseInt($count.text()) + increment)

    if increment == 1
      if type == 'fancy' && $trigger.hasClass('unfancied')
        $trigger
          .removeClass('unfancied')
          .addClass('fancied')
          .children('.fa')
          .removeClass('fa-heart-o')
          .addClass('fa-heart heartbeat')
          .one($.support.transition.end, -> $(this).removeClass('heartbeat'))
        updateFanciersCount()

      if type == 'own' && $trigger.hasClass('unowned')
        $trigger
          .removeClass('unowned')
          .addClass('owned')
        updateFanciersCount()
    else
      if type == 'fancy' && $trigger.hasClass('fancied')
        $trigger
          .removeClass('fancied')
          .addClass('unfancied')
          .children('.fa')
          .removeClass('fa-heart')
          .addClass('fa-heart-o heartbeat')
          .one($.support.transition.end, -> $(this).removeClass('heartbeat'))
        updateFanciersCount()

      if type == 'own' && $trigger.hasClass('owned')
        $trigger
          .removeClass('unowned')
          .addClass('owned')
        updateFanciersCount()

  initModel: ->
    firstTime = (@model.get('type') == 'fancy' && !@model.get('fancied')) ||
                (@model.get('type') == 'own' && @model.get('state') != 'owned')

    tagNames = @model.get('tags')
    tags = tagNames.map((name) -> {name, selected: true})
    recent_tags = @model.get('recent_tags').map((name) ->
      {name, selected: _.indexOf(tagNames, name) != -1}
    )
    popular_tags = @model.get('popular_tags').map((name) ->
      {name, selected: _.indexOf(tagNames, name) != -1}
    )

    @model.set({firstTime, tags, recent_tags, popular_tags})

  toggleTags: (tagNames, selected = 'toggle') ->
    toggle = (found) ->
      if found
        found.selected = if selected == 'toggle' then !found.selected else selected

    {tags, recent_tags, popular_tags} = @model.attributes

    _.uniq(tagNames).forEach((name) ->
      found = _.findWhere(tags, {name})
      tags.unshift({name, selected: true}) unless found

      toggle(found)
      toggle(_.findWhere(recent_tags, {name}))
      toggle(_.findWhere(popular_tags, {name}))
    )

    @model.trigger('change')

  addTags: (tagNames) ->
    @toggleTags(tagNames, true)

  onTagsFormSubmit: (event) ->
    event.preventDefault()

    tagNames = @ui.tagsInput.val().split(/[;；]/).filter((s) -> s && s.length <= 12)
    @addTags(tagNames)

    @ui.tagsInput.focus()

  onShow: ->
    @$el.modal('show')

  onRender: ->
    @$el.find('[name="score"]').rating()
