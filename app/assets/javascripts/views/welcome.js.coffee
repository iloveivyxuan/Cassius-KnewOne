do (exports = window.Making || {}) ->
  _hash = ''

  exports.InitWelcome = ->
    $ ->
      step  = location.hash
      $tags = $('#step2').find('.tags')
      cache = {}
      $things = $('#step2 ul.things')
      visibleCount = if $html.hasClass('mobile') then 6 else 12

      if step is '' then step = '#step1'
      $(step).addClass('is-active')

      $window
        .on 'hashchange', ->
          _hash = location.hash
          $(_hash).addClass('is-active').siblings().removeClass('is-active')
          $window.scrollTop(0)
        .on 'load', ->
          $window.trigger('hashchange')

      $tags.on 'click', 'a', (event) ->
        $this = $(@)

        if !$this.hasClass('is-active')
          keyword = $.trim($(@).data('slug'))
          if !cache[keyword]
            cache[keyword] = $.ajax
                              url: "/things/category/#{keyword}"
                              dataType: 'html'
                              data:
                                per: 12
          cache[keyword]
            .done (data, status, jqXHR) ->
              $things.empty().append(data)

      $('.js-friendship')
        .on 'click', '.js-friendship-follow-all', (event) ->
          event.preventDefault()
          $(event.delegateTarget)
            .find('.js-friendship-users')
            .find('.follow_btn[data-method="post"]')
            .slice(0, if location.hash is 'step3' and !$html.hasClass('mobile') then undefined else visibleCount)
            .click()
        .on 'click', '.js-friendship-refresh', (event) ->
          event.preventDefault()
          $list = $(event.delegateTarget).find('.js-friendship-users')
          $rest = $list
                    .children()
                    .slice(visibleCount)
          $list.prepend(_.sample($rest, visibleCount))

  #exports
  exports
