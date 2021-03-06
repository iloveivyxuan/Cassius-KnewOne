Making.InitThingList = (editable) ->
  $('input[name="show_price"]').on('change', (event) ->
    if $(this).is(':checked')
      $('.thing_list_items').addClass('thing_list_items--with_price')
    else
      $('.thing_list_items').removeClass('thing_list_items--with_price')
  )

  return unless editable

  originalClass = $('.thing_list_items').attr('class')

  $('.thing_list_name .editable').editable()

  $('.thing_list_description .editable').editable({
    emptytext: '描述一下吧'
    tpl: '<textarea maxlength="100"></textarea>'
  })

  $('.thing_list_item-description .editable').editable({
    emptytext: '说点什么吧（140字以内哦）'
    tpl: '<textarea maxlength="140"></textarea>'
  }).on('shown', (event, editable) ->
    setTimeout(->
      editable.input.$input.autosize()
    , 0)
  )

  $('.thing_list_description, .thing_list_item-description').on('keydown', (event) ->
    if event.which == 13 # ENTER
      event.preventDefault()
      $(this).find('.editableform').submit()
  )

  $('.editable').editable('disable')

  $('.thing_list_description.hide, .thing_list_item-description.hide').each(->
    $(this).removeClass('hide').hide()
  )

  $('.thing_list_items').sortable({
    disabled: true
    helper: 'clone'
    start: (event, ui) ->
      ui.placeholder.height(0)
    update: (event, ui) ->
      $el = ui.item

      prevOrder = parseFloat($el.prev().data('order')) if $el.prev().length
      nextOrder = parseFloat($el.next().data('order')) if $el.next().length
      prevOrder = nextOrder + 1 unless prevOrder?
      nextOrder = prevOrder - 1 unless nextOrder?
      newOrder = (prevOrder + nextOrder) / 2

      $el.data('order', newOrder)
      $.ajax({
        url: $el.data('url')
        type: 'PATCH'
        data: {thing_list_item: {order: newOrder}}
      })
    }
  )

  $('.thing_list_edit_button').on('click', (event) ->
    event.preventDefault()

    $target = $(this)

    if $target.text() == '管理'
      $target.text('完成')
      $('.thing_list_sorting_buttons').show()
      $('.thing_list_description, .thing_list_item-description').show()
      $('.thing_list_items')
        .attr('class', 'thing_list_items thing_list_items--editing')
        .sortable('enable')
    else
      $target.text('管理')
      $('.thing_list_sorting_buttons').hide()
      $('.editableform').submit()
      $('.thing_list_description, .thing_list_item-description').each(->
        $(this).hide() if $(this).find('.editable-empty').length
      $('.thing_list_items')
        .attr('class', originalClass)
        .sortable('disable')
      )

    $target.toggleClass('thing_list_edit_button--editing')
    $('.editable').editable('toggleDisabled')
  )

  changeBackground = (url) ->
    $('#thing_list_background').css('background-image', "url(#{url})")

  Making.imagePicker
    el: '#change_list_background_modal'
    after: ($activeItem, url) ->
      changeBackground($activeItem.data('url'))

      $.ajax({
        url: window.location.pathname
        type: 'PATCH'
        data: {thing_list: {background_id: $activeItem.data('id')}}
      })
