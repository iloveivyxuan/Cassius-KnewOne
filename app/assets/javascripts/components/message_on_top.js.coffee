Making.ShowMessageOnTop = (content, type = 'success', duration = 2000) ->
  html = HandlebarsTemplates['shared/message_on_top']({content, type})
  $('.message-on-top').replaceWith(html)
  setTimeout(->
    $('.message-on-top .alert').alert('close')
  , duration)
