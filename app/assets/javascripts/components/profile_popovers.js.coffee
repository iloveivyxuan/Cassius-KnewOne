Making.ProfilePopovers = ->
  calculatePlacement = (tip, element) ->
    $tip = $(tip)
    $element = $(element)

    tipWidth = $tip.appendTo($('body')).outerWidth()
    $tip.detach()

    elementOffsetRight = $element.offset().left + $element.outerWidth()

    if elementOffsetRight + tipWidth < $(window).width()
      'right'
    else if $element.offset().left > tipWidth
      'left'
    else if $element.offset().top > tipWidth
      'top'
    else
      'bottom'

  # http://stackoverflow.com/questions/15989591/
  initialize = ($element) ->
    return if  $element.data('bs.popover')

    $element.popover({
      container: 'body'
      content: '<i class="fa fa-spinner fa-spin"></i> 加载中'
      html: true
      placement: calculatePlacement
      trigger: 'manual'
    })

    $element.on('mouseleave', ->
      setTimeout(->
        $element.popover('hide') if $('.popover:hover').length == 0
      , 200)
    )

  show = _.debounce(($element, newContent) ->
    $('.popover').remove()

    return unless $element.is(':hover')

    $element.data('bs.popover').options.content = newContent
    $element.popover('show')

    $('.popover')
    .on('mouseleave', -> $element.popover('hide'))
    .on('click', '.follow_btn', ->
      userId = $element.attr('data-profile-popover')
      delete cache[userId]
    )
  , 200)

  cache = Object.create(null)
  selector = '[data-profile-popover]'

  $(document).on('mouseenter', selector, (event) ->
    return if $('html').is('.mobile')

    $target = $(this)

    initialize($target)

    userId = $target.attr('data-profile-popover')

    if cache[userId]
      return show($target, cache[userId])

    $.get("/users/#{userId}/profile", (html) ->
      cache[userId] = html
      show($target, html)
    )
  )
