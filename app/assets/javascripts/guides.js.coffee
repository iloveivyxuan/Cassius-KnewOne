class Guide
  constructor: ->
    @handleStepAdd()
    @handleStepRemove()
    $('#step_navs .step_nav:first a').tab('show')
    $('#step_navs').on 'shown', '.step_nav a', ->
      $('tbody.files').empty()

  handleStepAdd: ->
    $add = $('#add_step')
    $add.click (e) =>
      @newStep $add
      e.preventDefault()

  handleStepRemove: ->
    _remove_step = @removeStep
    $('#steps').on 'click', '.remove_step', (e) ->
      _remove_step parseInt($(this).data("remove"))
      e.preventDefault()

  newStep: ($add_step) ->
    r = new RegExp($add_step.data('id'), 'g')
    steps_length = $('#steps > fieldset').length
    navs_length = $('#step_navs .step_nav').length
    $('#steps').append $add_step.data("fields").replace(r, steps_length)
    $('.step_nav:last').after $add_step.data("nav").replace(r, steps_length)
    $("a[href=\"#step_#{steps_length}\"]").text(navs_length).tab('show')

  removeStep: (index) =>
    $("#step_#{index}")
      .find("input[type=hidden]").val('1').end()
    .hide()
    $("a[href=\"#step_#{index}\"]").closest(".step_nav")
      .nextAll(".step_nav").find('a')
        .text( (index, text) ->
          parseInt(text) - 1
        ).end()
      .end()
      .prev().find('a')
        .tab('show').end()
      .end()
    .remove()

$ ->
  new Guide()
