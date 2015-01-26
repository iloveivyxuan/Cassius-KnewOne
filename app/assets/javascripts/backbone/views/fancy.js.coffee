class Making.Views.FancyModal extends Backbone.Marionette.ItemView
  id: 'fancy_modal'
  className: 'modal fade'
  template: HandlebarsTemplates['fancy/modal']

  ui: {
    tagsForm: '.fancy_modal-tags_form'
    tagsInput: '[name="tag_names"]'
  }

  events: {
    'hidden.bs.modal': 'destroy'
    'change input, textarea': 'onInputChange'
    'submit @ui.tagsForm': 'onTagsFormSubmit'
    'click .fancy_modal-all_tags li': 'onTagClick'
    'click .fancy_modal-state input': 'onStateClick'
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
    recent_tags = @model.get('recent_tags')
      .filter((name) -> _.indexOf(tagNames, name) == -1)
      .map((name) -> {name, selected: false})
    popular_tags = @model.get('popular_tags')
      .filter((name) -> _.indexOf(tagNames, name) == -1)
      .map((name) -> {name, selected: false})

    @model.set({firstTime, tags, recent_tags, popular_tags})

  toggleTags: (tagNames, selected = 'toggle') ->
    toggle = (found) ->
      if found
        found.selected = if selected == 'toggle' then !found.selected else selected

    {tags, recent_tags, popular_tags} = @model.attributes

    _.uniq(tagNames).forEach((name) ->
      found = _.findWhere(tags, {name})
      found2 = _.findWhere(recent_tags, {name})
      found3 = _.findWhere(popular_tags, {name})

      if found || found2 || found3
        toggle(found)
        toggle(found2)
        toggle(found3)
      else
        tags.unshift({name, selected: true})
    )

    @model.trigger('change')

  addTags: (tagNames) ->
    @toggleTags(tagNames, true)

  onInputChange: (event) ->
    $input = $(event.currentTarget)
    change = {}
    change[$input.attr('name')] = $input.val()
    @model.set(change)

  onTagsFormSubmit: (event) ->
    event.preventDefault()

    tagNames = @ui.tagsInput.val()
      .split(/[;；]/)
      .map((s) -> s.trim())
      .filter((s) -> s && s.length <= 12)
    @addTags(tagNames)

    @ui.tagsInput.focus()

  onTagClick: (event) ->
    name = $(event.currentTarget).text()
    @toggleTags([name])

  onStateClick: (event) ->
    $radio = $(event.currentTarget)

    if $radio.val() == @model.get('state')
      @$('[name="state"][value="none"]').prop('checked', true)
      @model.set('state', 'none')
    else
      $radio.prop('checked', true)
      @model.set('state', $radio.val())

  onShow: ->
    @$el.modal('show')

  onRender: ->
    @$el.find('[name="score"]').rating()
