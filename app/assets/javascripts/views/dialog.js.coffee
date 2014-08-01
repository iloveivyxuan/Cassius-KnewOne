Making.DialogPage =
  InitIndex: ->
    $(->
      $('.private_message').on('click', ->
        window.location = $(this).find('.messages_count a').attr('href')
      )
    )
