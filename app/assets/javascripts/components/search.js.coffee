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
      $form
        .removeClass('focus')
        .one($.support.transition.end, -> $nav_primary.fadeIn())
    )
)
