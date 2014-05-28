Making.PrivateMessage = ->
  selector = '[data-private-message]'

  $modal = $('#new_private_message_modal')

  $(document).on('click', selector, (event) ->
    $target = $(event.target)
    $target = $target.parents(selector) unless $target.is(selector)

    userId   = $target.attr('data-user-id')
    userName = $target.attr('data-user-name')

    $modal.find('#dialog_user_id').val(userId)
    $modal.find('#dialog_user_name').val(userName)
    $modal.find('#dialog_user_name').prop('disabled', true)

    $modal.modal('show')
    setTimeout(->
      $modal.find('#dialog_content').focus()
    , 1000)
  )
