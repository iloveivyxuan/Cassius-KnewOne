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

  onShow: ->
    @$el.modal('show')

  onRender: ->
    @$el.find('[name="score"]').rating()
