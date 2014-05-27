do (exports = Making) ->
  class exports.View.Menu
    constructor: (element, container, toggle) ->
      @$el          = $(element)
      @$container   = $(container)
      @$toggle      = $(toggle)
      @$backdrop    = $('<div class="menu_backdrop"></div>')
      @active_class = 'menu_open'

      _.bindAll(@, 'show', 'hide')

      @$toggle.on 'tap click', @show

    show: (event) ->
      event.preventDefault()

      @$backdrop.clone()
        .on 'tap click', @hide
        .addClass('in')
        .appendTo(@$container)

      @$container.addClass(@active_class)

    hide: ->
      @$container
        .removeClass(@active_class)
        .find('.menu_backdrop')
        .remove()

  return
