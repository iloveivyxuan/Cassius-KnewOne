$('#new_topic').on 'submit', ->
  $(@).find('button[type="submit"]').attr('disabled', 'disabled').text('提交中')
