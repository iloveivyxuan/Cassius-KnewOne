Making.initSearchForm = (form) ->
  new Making.Views.SearchForm(el: form)

$(->
  $form = $('#navbar_search')
  $nav_primary = $('#nav_primary')
  $input = $form.find('input[type="search"]')

  return if $form.length == 0

  $input
    .on('focus', ->
      $nav_primary.hide()
      $form.addClass('focus')
    )
    .on('blur', ->
      return if Making.isDebugging()

      $form.removeClass('focus')

      if Modernizr.csstransitions
        $form.one($.support.transition.end, -> $nav_primary.fadeIn())
      else
        $nav_primary.show()
    )

  Making.initSearchForm($form)
) if $('html').hasClass('desktop')
