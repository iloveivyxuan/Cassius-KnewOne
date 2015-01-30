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
    'click .fancy_modal-cancel_button': 'onCancel'
    'click .fancy_modal-submit_button': 'onSubmit'
  }

  modelEvents: {
    change: 'render'
  }

  initialize: ->
    @initModel()
    @updateStateOnServer()
    @updateAllTriggers()

  url: (suffix = '') ->
    "/things/#{@model.get('thing_id')}/impression#{suffix}"

  initModel: ->
    first_time = (@model.get('type') == 'fancy' && !@model.get('fancied')) ||
                (@model.get('type') == 'own' && @model.get('state') != 'owned')

    tagNames = @model.get('tags')
    tags = tagNames.map((name) -> {name, selected: true})
    recent_tags = @model.get('recent_tags')
      .filter((name) -> _.indexOf(tagNames, name) == -1)
      .map((name) -> {name, selected: false})
    popular_tags = @model.get('popular_tags')
      .filter((name) -> _.indexOf(tagNames, name) == -1)
      .map((name) -> {name, selected: false})

    sync_to_feeling = !@model.get('description')

    @model.set({first_time, tags, recent_tags, popular_tags, sync_to_feeling})

  updateStateOnServer: ->
    {type, fancied, state} = @model.attributes

    return if type == 'edit' || (type == 'fancy' && fancied) || (type == 'own' && state == 'owned')

    if @model.get('type') == 'fancy'
      change = {fancied: true}
    else
      change = {state: 'owned'}

    @model.set(change, {silent: true})

    $.ajax({
      url: @url('.js')
      type: 'PATCH'
      data: {impression: change}
    }, eval)

  updateAllTriggers: ->
    {thing_id, fancied, state} = @model.attributes

    updateCount = ($count, increment) ->
      $humanizedNumber = $count.find('.humanized_number')
      if $humanizedNumber.length
        $humanizedNumber.attr('title', parseInt($humanizedNumber.attr('title')) + increment)
      else
        $count.text(parseInt($count.text()) + increment)

    updateTrigger = ($trigger, title, triggerClass, iconClass, animation = 'heartbeat') ->
      $trigger
        .attr('title', title)
        .attr('class', triggerClass)
        .children('.fa')
        .attr('class', "fa #{iconClass}")
        .addClass(animation)
        .one(Making.prefixEvent('AnimationEnd'), -> $(this).removeClass(animation))

    $("[data-fancy='#{thing_id}']").each(->
      $trigger = $(this)
      type = $trigger.data('type')

      if type == 'fancy'
        $count = $trigger.find('.fanciers_count')
      else
        $count = $trigger.find('.owners_count')

      if type == 'fancy'
        if $trigger.hasClass('unfancied') && fancied
          updateCount($count, 1)
          updateTrigger($trigger, '修改喜欢状态', (if state == 'desired' then state else 'fancied'), 'fa-heart')
        else if ($trigger.hasClass('fancied') || $trigger.hasClass('desired')) && !fancied
          updateCount($count, -1)
          updateTrigger($trigger, '喜欢此产品', "unfancied", 'fa-heart-o')
        else if $trigger.hasClass('fancied') && state == 'desired'
          updateTrigger($trigger, '修改喜欢状态', "desired", 'fa-desire', 'swing')
        else if $trigger.hasClass('desired') && state != 'desired'
          updateTrigger($trigger, '修改喜欢状态', "fancied", 'fa-heart')
      else if type == 'own'
        if $trigger.hasClass('unowned') && state == 'owned'
          updateCount($count, 1)
          updateTrigger($trigger, '修改拥有状态', 'owned', 'fa-check-circle-o', 'flip')
        else if $trigger.hasClass('owned') && state != 'owned'
          updateCount($count, -1)
          updateTrigger($trigger, '拥有此产品', 'unowned', 'fa-circle-o', 'flip')
    )

  onShow: ->
    @$el.modal('show')

  onRender: ->
    @$el.find('[name="score"]').rating()

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

    return if $input.attr('name') == 'state'

    change = {}
    change[$input.attr('name')] = $input.val()
    @model.set(change, {silent: true})

  onTagsFormSubmit: (event) ->
    event.preventDefault() if event

    tagNames = @ui.tagsInput.val()
      .split(/[,，]/)
      .map((s) -> s.trim())
      .filter((s) -> s && s.length <= 12)
    @model.set({tag_names: ''}, {silent: true})
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

  onCancel: ->
    return if @model.get('type') == 'edit'

    if @model.get('type') == 'fancy'
      change = {fancied: false}
    else
      change = {state: 'none'}

    @model.set(change, {silent: true})

    $.ajax({
      url: @url('.js')
      type: 'PATCH'
      data: {impression: change}
    }, eval)

    @$el.modal('hide')

    @updateAllTriggers()

  tryToSyncToFeeling: ->
    return unless @model.get('sync_to_feeling') && @model.get('description')

    feeling = {
      content: @model.get('description')
      score: @model.get('score')
    }

    $.ajax({
      url: "/things/#{@model.get('thing_id')}/feelings"
      type: 'POST'
      data: {feeling}
    })

  onSubmit: ->
    @onTagsFormSubmit()

    data = _.pick(@model.attributes, 'state', 'description', 'score')

    {tags, recent_tags, popular_tags} = @model.attributes
    data.tag_names = _.chain([tags, recent_tags, popular_tags])
      .flatten()
      .filter(({selected}) -> selected)
      .pluck('name')
      .value()
      .join(',')

    $.ajax({
      url: @url('.js')
      type: 'PATCH'
      data: {impression: data}
    }, eval)

    @tryToSyncToFeeling()

    @$el.modal('hide')

    @updateAllTriggers()