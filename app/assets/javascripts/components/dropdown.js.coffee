# Dropdown Menu
do (exports = Making, $ = jQuery) ->
  $menu = $('.dropdown-menu')
  if $menu.find('.dropdown-submenu').length
    $menu.menuAim
      activate: (row) ->
        $(row).addClass('is-active')
      deactivate: (row) ->
        $(row).removeClass('is-active')
      enter: ->
        $menu.addClass('is-expand')
      exitMenu: ->
        $menu.removeClass('is-expand')
        return true

  return

# Dropdown Box
do (exports = Making, $ = jQuery) ->

  toggle = '[data-toggle="dropdown_box"]'

  class DropdownBox

    constructor: (element, options) ->
      @$element = $(element)
      @$parent  = @$element.closest('.dropdown')
      @$box     = @$element.next('.dropdown_box')
      @options  = options

      @$box
        .on 'click', (event) ->
          event.stopPropagation() unless $(event.target).hasClass('dropdown_box_propagate')
        .on 'mouseenter', ->
          $docbody.trigger 'freeze'
        .on 'mouseleave', ->
          $docbody.trigger 'unfreeze'

    toggle: ->
      @$parent.toggleClass('open')

  clear_boxes = ->
    $(toggle).each ->
      $(@).closest('.dropdown').removeClass('open')

  old = $.fn.dropdownbox

  $.fn.dropdownbox = (option) ->
    return @each ->
      $this   = $(@)
      data    = $this.data 'dropdownbox'
      options = $.extend(
        {}
        DropdownBox.DEFAULTS
        $this.data()
        typeof option is 'object' && option
      )

      if (!data) then $this.data('dropdownbox', (data = new DropdownBox(this, options)))
      if (typeof option is 'string') then data[option]()
      return

  $.fn.dropdownbox.Constructor = DropdownBox

  $.fn.dropdownbox.noConflict = ->
    $.fn.dropdownbox = old;
    @

  $(document)
    .on 'click.dropdownbox.data-api', '[data-toggle="dropdown_box"]', (event) ->
      $(@).dropdownbox('toggle')
      false
    .on 'click.dropdownbox.data-api', (event) ->
      # TODO
      clear_boxes() unless $(event.target).hasClass('dropdown_box_propagate')

  return
