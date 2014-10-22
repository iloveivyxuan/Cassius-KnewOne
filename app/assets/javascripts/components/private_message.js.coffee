Making.PrivateMessage = ->
  selector = '[data-private-message]'

  $modal = $('#new_private_message_modal')

  $(document).on('click', selector, (event) ->
    $target = $(this)

    userId   = $target.attr('data-user-id')
    userName = $target.attr('data-user-name')
    messageContent = $target.attr('data-content')

    $modal.find('#dialog_user_id').val(userId)
    $modal.find('#dialog_user_name').val(userName)
    if messageContent
      $modal.find('#dialog_content').val(messageContent)
    $modal.find('#dialog_user_name').prop('disabled', true)

    $modal.modal('show')
    setTimeout(->
      $modal.find('#dialog_content').focus()
    , 1000)
  )
