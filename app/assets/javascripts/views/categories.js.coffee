do (exports = Making, $ = jQuery) ->

  exports.InitCategories = ->

    $('.category_block').each ->
      $category      = $(@)
      $tagsContainer = $category.find('.tags_container')
      $tags          = $tagsContainer.find('.tags')
      $prev          = $category.find('footer a[rel="prev"]')
      $next          = $category.find('footer a[rel="next"]')
      pageHeight     = $tagsContainer.height()
      tagsHeight     = $tags.height()

      checkPager = (past) ->
        $prev[if past < 0 then 'show' else 'hide']()
        $next[if tagsHeight + past > pageHeight then 'show' else 'hide']()
        return

      checkPager(0)

      $category
        .on 'click', 'footer a[rel]', (event) ->
          event.preventDefault()

          $pager    = $(event.target)
          direction = $pager.attr('rel')
          marginTop = parseInt($tags.css('marginTop'))

          switch direction
            when 'prev'
              foo = pageHeight
            when 'next'
              foo = -pageHeight
          $tags
            .hide()
            .css('marginTop', marginTop + foo + 'px')
            .fadeIn()

          checkPager(parseInt($tags.css('marginTop')))

  return exports
