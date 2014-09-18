# Dropdown Menu
do (exports = Making, $ = jQuery) ->
  $menu = $('.dropdown-menu')
  if $menu.find('.dropdown-submenu').length
    $menu.menuAim
      activate: (row) ->
        $(row).addClass('is-active')
      deactivate: (row) ->
        $(row).removeClass('is-active')
      exitMenu: ->
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
      # TODO
      scrollbar_width = exports.GetScrollbarWidth()
      $navbar         = $('.navbar')

      @$box
        .on 'click', (event) ->
          event.stopPropagation() unless $(event.target).hasClass('dropdown_box_propagate')
        # TODO
        .on 'mouseenter', ->
          $docbody.addClass('dropdown_box_open')
          if scrollbar_width > 0 and $document.height() > $window.height()
            $html.css 'margin-right', scrollbar_width + 'px'
            $navbar.css 'padding-right', scrollbar_width + 'px'
        .on 'mouseleave', ->
          $docbody.removeClass('dropdown_box_open')
          if scrollbar_width > 0 and $document.height() > $window.height()
            $html.css 'margin-right', 0
            $navbar.css 'padding-right', 0

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
