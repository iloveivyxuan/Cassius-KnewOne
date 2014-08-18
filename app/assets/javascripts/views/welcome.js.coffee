do (exports = window.Making || {}) ->
  _hash = ''

  exports.InitWelcome = ->
    $ ->
      step  = location.hash
      $tags = $('#step2').find('.tags')
      cache = {}
      $things = $('#step2 ul.things')

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

  #exports
  exports
