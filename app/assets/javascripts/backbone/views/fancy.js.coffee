class Making.Views.FancyModal extends Backbone.Marionette.ItemView
  id: 'fancy_modal'
  className: 'modal fade'
  template: HandlebarsTemplates['fancy/modal']

  ui: {
    textarea: 'textarea'
    tagsForm: '.fancy_modal-tags_form'
    tagsInput: '[name="tag_names"]'
    selectizeInput: '.selectize-input input[type="text"]'
  }

  events: {
    'hidden.bs.modal': 'destroy'
    'change input, textarea': 'onInputChange'
    'keyup textarea': 'onTextAreaKeyUp'
    'keyup @ui.selectizeInput': 'fixFullWidthComma'
    'click .fancy_modal-tags_form_toggle': 'toggleTagsForm'
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

    tags = @model.get('tags') || []
    tag_names = tags.join(',')
    recent_tags = (@model.get('recent_tags') || [])
      .filter((name) -> _.indexOf(tags, name) == -1)
      .map((name) -> {name, selected: false})
    popular_tags = (@model.get('popular_tags') || [])
      .filter((name) -> _.indexOf(tags, name) == -1)
      .map((name) -> {name, selected: false})

    @model.set({first_time, tags, tag_names, recent_tags, popular_tags})

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
        .removeClass('unfancied fancied desired unowned owned')
        .children('.fa')
        .attr('class', "fa #{iconClass}")
        .addClass(animation)
        .one(Making.prefixEvent('AnimationEnd'), ->
          $(this).removeClass(animation)
          $trigger.addClass(triggerClass)
        )

    $("[data-fancy='#{thing_id}']").each(->
      $trigger = $(this)
      data = $trigger.data()

      if data.type == 'fancy'
        $count = $trigger.find('.fanciers_count')
      else
        $count = $trigger.find('.owners_count')

      if data.type == 'fancy'
        if !data.fancied && fancied
          updateCount($count, 1)
          updateTrigger($trigger, '修改产品印象', (if state == 'desired' then state else 'fancied'), 'fa-heart')
        else if data.fancied && !fancied
          updateCount($count, -1)
          updateTrigger($trigger, '喜欢此产品', 'unfancied', 'fa-heart-o')
        else if data.state != 'desired' && state == 'desired'
          updateTrigger($trigger, '修改产品印象', 'desired', 'fa-desire', 'swing')
        else if data.state == 'desired' && state != 'desired'
          updateTrigger($trigger, '修改产品印象', 'fancied', 'fa-heart')
      else if data.type == 'own'
        if data.state != 'owned' && state == 'owned'
          updateCount($count, 1)
          updateTrigger($trigger, '修改产品印象', 'owned', 'fa-check-circle-o', 'flip')
        else if data.state == 'owned' && state != 'owned'
          updateCount($count, -1)
          updateTrigger($trigger, '拥有此产品', 'unowned', 'fa-circle-o', 'flip')

      $trigger.data({fancied, state})
    )

  onShow: ->
    if @model.get('first_time')
      @destroy()
    else
      @$el.modal('show')

  onRender: ->
    @$('[name="score"]').rating()

    plugins = {}
    plugins.remove_button = {title: '删除标签'} if Modernizr.touch

    @ui.tagsInput.selectize({
      plugins
      delimiter: ','
      splitOn: /\s*[,，]\s*/
      createOnBlur: true
      persist: false
      create: (input, done) =>
        input = input.trim()

        if input.length >= 20
          @model.set({tags_too_long: true})
          done()
        else
          @model.set({tags_too_long: false}, {silent: true})
          done({value: input, text: input})

      onItemAdd: (value) =>
        tag_names = @_selectize.getValue()
        @model.set({tag_names, tags: tag_names.split(',')}, {silent: true})
        @toggleTags([value], true)

      onItemRemove: (value) => @toggleTags([value], false)
    })

    @_selectize = @ui.tagsInput[0].selectize

    @bindUIElements()

  toggleTags: (tagNames, selected = 'toggle') ->
    toggle = (found) ->
      if found
        found.selected = if selected == 'toggle' then !found.selected else selected

    {tags, recent_tags, popular_tags} = @model.attributes

    _.uniq(tagNames).forEach((name) =>
      if _.indexOf(tags, name) == -1
        tags.push(name) if selected == 'toggle' || selected
      else
        tags = _.without(tags, name) if selected == 'toggle' || !selected

      toggle(_.findWhere(recent_tags, {name}))
      toggle(_.findWhere(popular_tags, {name}))
    )

    @model.set({tags, tag_names: tags.join(',')}, {silent: true})
    @model.trigger('change')

    @ui.selectizeInput.focus()
    setTimeout(=>
      @ui.selectizeInput.focus()
    , 0)

  onInputChange: (event) ->
    $input = $(event.currentTarget)

    return if $input.attr('name') == 'state'

    change = {}
    change[$input.attr('name')] = $input.val()
    @model.set(change, {silent: true})

  onTextAreaKeyUp: ->
    @$('.word_counter b').text(@ui.textarea.val().length)

  fixFullWidthComma: (event) ->
    $input = $(event.currentTarget)
    $input.trigger('paste') if /，/.test($input.val())

  toggleTagsForm: (event) ->
    event.preventDefault()

    @ui.tagsForm.slideToggle(300, =>
      @model.set({tags_expanded: !@model.get('tags_expanded')})
    )

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

  onCancel: (event) ->
    event.preventDefault()

    switch @model.get('type')
      when 'fancy'
        return unless confirm('您确定要取消喜欢吗？')
      when 'own'
        return unless confirm('您确定要取消拥有吗？')
      else
        return

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

  onSubmit: (event) ->
    event.preventDefault()

    impression = _.pick(@model.attributes, 'state', 'description', 'score', 'tag_names')

    $.ajax({
      url: @url('.js')
      type: 'PATCH'
      data: {impression, from: @model.get('from')}
    }, eval)

    @$el.modal('hide')

    Making.ShowMessageOnTop('操作成功，感谢您的分享')

    @updateAllTriggers()
