do (exports = Making, $ = jQuery) ->

  exports.validator = (form = 'form:not(novalidate)', options) ->
    $form    = $(form)
    identifie = '[required]'
    $identifie = $(identifie)
    $submit  = $form.find('[type="submit"]')
    defaults =
                validator:
                  identifie: identifie
                  error: 'is-invalid'
                  isErrorOnParent: true

    options  = _.extend {}, defaults, options

    $identifie.attr('data-event', 'validate')
    $form.validator(options.validator)

    $form.on 'change keyup focusin focusout', '.form-control', (event) ->
      $control = $(event.currentTarget)
      $group   = $control.closest('.form-group')

      switch event.type
        when 'focusin'
          $group
            .addClass('is-focused')
            .removeClass('is-invalid')
            .find('ul.help-block')
            .empty()
          $form.find('.form-results').addClass('hidden')
        when 'change', 'keyup'
          $group[if $control.val() is '' then 'removeClass' else 'addClass']('is-filled')
        when 'focusout'
          $group.removeClass('is-focused')

    $identifie.on 'after:validate', (event, element) ->
      $control = $(element)
      $group   = $control.closest('.form-group')

      if $group.hasClass('is-invalid')
        $label  = $group.children('label')
        $help   = $group.find('ul.help-block')
        message = ''

        if $group.hasClass('empty')
          message = $label.text() + '不能为空'
        else
          message = $control.data('message-error')
        $help.empty().html('<li>' + message + '</li>')
        $submit.disable()
      else if $form.find('.is-invalid').length is 0
        $submit.enable()

  exports.showValidateResults = (form, results) ->
    $form = $(form)

    for key, messages of results
      messagesHtml = ''

      messages.forEach (message) ->
        messagesHtml += '<li>' + message + '</li>'

      $form
        .find('[name="' + key + '"]')
        .closest('.form-group')
          .addClass('is-invalid')
        .find('ul.help-block')
          .empty()
          .html(messagesHtml)
    $form.find('[type="submit"]').disable()

  exports.validatePhone = (element) ->
    $(element).on 'change', (event) ->
      if (isNaN(this.value) or this.value.length != 11)
        alert('请填写有效的手机号码。')
        this.value=''

  return
