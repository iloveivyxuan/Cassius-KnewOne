window.Making = do (exports = window.Making || {}) ->
  _hash = ''

  exports.InitWelcome = ->
    $ ->
      $window = $(window)
      step = location.hash
      $button_finish = $('.js_finish')
      $form_fill = $('#fill_info')

      if step is '' then step = '#step1'
      $(step).addClass('active')

      $window
        .on 'hashchange', ->
          _hash = location.hash
          $(_hash).addClass('active').siblings().removeClass('active')
          $(@).scrollTop(0);
        .on 'load', ->
          $(@).trigger('hashchange')

      $('#step3').children('form').find('.close').on 'click', ->
        $(@).parents('form').slideUp(200)

      $button_finish.on 'click', (event) ->
        if $form_fill.length > 0
          event.preventDefault()
          if $(@).parents('.step_header').length is 0
            $window.scrollTop(0)
          $button_finish.hide()
          $form_fill.show()

        true

  #exports
  exports