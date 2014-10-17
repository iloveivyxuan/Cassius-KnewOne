$(document).on('click', 'a[href*=#]:not([href=#])', (event) ->
  $target = $(this.hash)

  return if $target.length == 0

  event.preventDefault()
  $('html, body').animate({scrollTop: $target.offset().top - 100}, 'slow')
)
