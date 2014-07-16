Making.PopoverProfiles = ->
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

  show = ($element, newContent) ->
    $element.data('bs.popover').options.content = newContent

    $('.popover').remove()
    $element.popover('show')

    $('.popover')
    .addClass('profile')
    .on('mouseleave', -> $element.popover('hide'))
    .on('click', '.follow_btn', ->
      userId = $element.attr('data-popover-profile')
      delete cache[userId]
    )

  cache = Object.create({})
  selector = '[data-popover-profile]'

  $(document).on('mouseenter', selector, (event) ->
    return if $('html').is('.mobile')

    $target = $(this)

    initialize($target)

    userId = $target.attr('data-popover-profile')

    if cache[userId]
      return show($target, cache[userId])

    $.get("/users/#{userId}/profile", (html) ->
      cache[userId] = html
      show($target, html)
    )
  )
