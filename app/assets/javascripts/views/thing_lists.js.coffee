Making.InitThingList = ->
  originalClass = $('.thing_list_items').attr('class')

  $('.thing_list_name .editable').editable()

  $('.thing_list_description .editable').editable({
    emptytext: '描述一下吧'
  })

  $('.thing_list_item-description .editable').editable({
    emptytext: '说点什么吧（50字以内哦）'
    tpl: '<input type="text" maxlength="50">'
  })

  $('.editable').editable('disable')

  $('.thing_list_description.hide, .thing_list_item-description.hide').each(->
    $(this).removeClass('hide').hide()
  )

  $('.thing_list_edit_button').on('click', (event) ->
    event.preventDefault()

    $target = $(this)

    if $target.text() == '管理'
      $target.text('完成')
      $('.thing_list_description, .thing_list_item-description').show()
      $('.thing_list_items').attr('class', 'thing_list_items')
    else
      $target.text('管理')
      $('.thing_list_description, .thing_list_item-description').each(->
        $(this).hide() if $(this).find('.editable-empty').length
      $('.thing_list_items').attr('class', originalClass)
      )

    $target.toggleClass('thing_list_edit_button--editing')
    $('.editable').editable('toggleDisabled')
  )
