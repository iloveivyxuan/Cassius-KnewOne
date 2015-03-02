# Disable
#-------------------------------------------------------------------------------

( ->
  old = $.fn.disable

  $.fn.disable = (klass = 'disabled') ->
    return @each ->
      $element = $(@)
      node_name = $element[0].nodeName.toLowerCase()

      switch node_name
        when 'input', 'button'
          $element
            .attr('disabled', true)

      $element
        .addClass(klass)
        .data('disabled-class', klass)

  $.fn.disable.noConflict = ->
    $.fn.disable = old
    return @
)()

# Enable
#-------------------------------------------------------------------------------

( ->
  old  = $.fn.enable

  $.fn.enable = ->
    return @each ->
      $element = $(@)
      node_name = $element[0].nodeName.toLowerCase()
      klass = $element.data('disabled-class') || 'disabled'

      switch node_name
        when 'input', 'button'
          $element
            .removeAttr('disabled')

      $element
        .removeClass(klass)

  $.fn.enable.noConflict = ->
    $.fn.enable = old
    return @
)()
