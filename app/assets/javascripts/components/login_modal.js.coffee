do (exports = Making) ->
  exports.loginModal = ->
    $modal         = $('#login-modal')
    $dialogWrapper = $modal.find('.modal-dialog_wrapper')
    $dialogSignin  = $dialogWrapper.find('.modal-dialog--signin')
    $dialogSignup  = $dialogWrapper.find('.modal-dialog--signup')
    $legendSignin  = $dialogSignin.find('legend')
    $flipper       = $modal.find('.modal-flipper')

    $flipper.on 'click', (event) ->
      event.preventDefault()
      $dialogWrapper.toggleClass('is-flipped')

    $modal.on 'show.bs.modal', (event) ->
      if exports.browser == 'wechat'
        event.preventDefault()
        return Making.logIntoWechat()

      $button    = $(event.relatedTarget)
      actionType = $button.data('action-type') || 'signin'

      switch actionType
        when 'signup'
          $legendSignin.text('登录')
          $dialogWrapper.addClass('is-flipped')
        when 'signin'
          $legendSignin.text($button.data('signin-legend') || '登录')
          $dialogWrapper.removeClass('is-flipped')

    $modal.find('.button--clear').on 'click', (event)->
      event.preventDefault()
      $(@)
        .closest('.form-group')
          .removeClass('is-filled')
        .children('.form-control')
          .val('')
          .focus()

    exports.validator('#signup_form')
    exports.validator('#signin_form')
    exports.validator('#find_password_form')
