do (exports = Making) ->
  exports.loginModal = ->
    $modal         = $('#login-modal')
    $dialogWrapper = $modal.find('.modal-dialog_wrapper')
    $dialogSignin  = $dialogWrapper.find('.modal-dialog--signin')
    $dialogSignup  = $dialogWrapper.find('.modal-dialog--signup')
    $flipper       = $modal.find('.modal-flipper')

    $flipper.on 'tap click', (event) ->
      event.preventDefault()
      $dialogWrapper.toggleClass('is-flipped')

    $modal.on 'show.bs.modal', (event) ->
      $button       = $(event.relatedTarget)
      actionType    = $button.data('action-type')
      legendSignin  = $button.data('signin-legend') || '登录'

      $dialogSignin.find('legend').text(legendSignin)

      if actionType is 'signup'
        $dialogWrapper.removeClass('is-flipped') if $dialogWrapper.hasClass('is-flipped')
        $dialogSignin
          .removeClass('modal-dialog--front')
          .addClass('modal-dialog--back')
        $dialogSignup
          .removeClass('modal-dialog--back')
          .addClass('modal-dialog--front')

    $modal.find('.button--clear').on 'tap click', (event)->
      event.preventDefault()
      $(@)
        .closest('.form-group')
        .children('.form-control')
        .val('')
        .trigger('change')

    exports.validator('#signup_form')
    exports.validator('#signin_form')
    exports.validator('#find_password_form')
