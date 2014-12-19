Making.initSearchForm = (form) ->

$(->
  $form = $('#navbar_search')
  $nav_primary = $('#nav_primary')

  return if $form.length == 0

  Making.initSearchForm($form)

  $('#navbar_search')
    .on('focus', 'input[type="search"]', ->
      $nav_primary.hide()
      $form.addClass('focus')
    )
    .on('blur', 'input[type="search"]', ->
      $form.removeClass('focus')

      if Modernizr.csstransitions
        $form.one($.support.transition.end, -> $nav_primary.fadeIn())
      else
        $nav_primary.show()
    )
)
