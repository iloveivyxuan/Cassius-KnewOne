Making.PopoverProfiles = ->
  # http://stackoverflow.com/questions/15989591/
  initialize = ($element) ->
    $element.popover({
      container: 'body'
      content: '<i class="fa fa-spinner fa-spin"></i> 加载中'
      html: true
      placement: 'auto right'
      trigger: 'manual'
    }) unless $element.data('bs.popover')

    $element.popover('show')

    $('.popover').on('mouseleave', -> $element.popover('hide'))

    $element.on('mouseleave', ->
      setTimeout(->
        $element.popover('hide') if $('.popover:hover').length == 0
      , 200)
    )

  update = ($element, newContent) ->
    $element.data('bs.popover').options.content = newContent
    $element.popover('show')

  cache = Object.create({})
  selector = '[class$="_author"], .comment > .avatar'

  $(document).on('mouseenter', selector, (event) ->
    $target = $(event.target)
    $target = $target.parents(selector) unless $target.is(selector)

    initialize($target)

    url = $target.find('a[href^="/users/"]').attr('href')

    if cache[url]
      return update($target, cache[url])

    $.get("#{url}/profile", (html) ->
      cache[url] = html
      update($target, html)
    )
  )
