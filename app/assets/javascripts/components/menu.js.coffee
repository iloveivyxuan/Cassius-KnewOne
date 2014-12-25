do (exports = Making) ->
  class exports.View.Menu
    constructor: (element, container, toggle) ->
      @$element     = $(element)
      @$container   = $(container)
      @$toggle      = $(toggle)
      @$close       = @$element.find('.menu-close')
      @$backdrop    = $('<div class="menu-backdrop"></div>')
      @activeClass  = 'menu-open'

      _.bindAll(@, 'show', 'hide')

      @$toggle.on 'tap click', @show
      @$close.on 'tap click', @hide

    show: (event) ->
      event.preventDefault()

      @$backdrop.clone()
        .on 'tap click', @hide
        .addClass('in')
        .appendTo(@$container)

      @$container.addClass(@activeClass)

    hide: (event) ->
      event.preventDefault()

      @$container
        .removeClass(@activeClass)
        .find('.menu-backdrop')
        .remove()

  return
