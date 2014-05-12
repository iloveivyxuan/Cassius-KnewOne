do (exports = Making) ->

  exports.offcanvas = ->
    $wrapper      = $('#wrapper')

    $wrapper
      .on 'click', '.toggle', ->
        $target = $(@)

        if $target.hasClass('left')
          $wrapper.addClass('active_nav')
        else if $target.hasClass('right')
          $wrapper.removeClass('active_nav')
