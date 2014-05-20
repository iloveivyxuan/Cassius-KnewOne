Making.PopoverProfiles = ->
  # http://stackoverflow.com/questions/15989591/
  initialize = ($element) ->
    return if  $element.data('bs.popover')

    $element.popover({
      container: 'body'
      content: '<i class="fa fa-spinner fa-spin"></i> 加载中'
      html: true
      placement: 'auto right'
      trigger: 'manual'
    })

    $element.on('mouseleave', ->
      setTimeout(->
        $element.popover('hide') if $('.popover:hover').length == 0
      , 200)
    )

  show = ($element, newContent) ->
    $element.data('bs.popover').options.content = newContent
    $element.popover('show')

    $('.popover').on('mouseleave', -> $element.popover('hide'))

  cache = Object.create({})
  selector = '[data-popover-profile]'

  $(document).on('mouseenter', selector, (event) ->
    $target = $(event.target)
    $target = $target.parents(selector) unless $target.is(selector)

    initialize($target)

    userId = $target.attr('data-popover-profile')

    if cache[userId]
      return show($target, cache[userId])

    $.get("/users/#{userId}/profile", (html) ->
      cache[userId] = html
      show($target, html)
    )
  )
