Making.CartItemNew = ->
  $ ->
    $form = $('#new_cart_item')
    $price = $('.price small')
    thing_price = $price.text()

    set_price = (price) ->
      $price.text (price or thing_price)

    set_estimated = (estimated) ->
      $prompt = $('.cart_estimated_prompt').hide()
      if estimated
        $prompt.find('time').replaceWith(estimated).end().fadeIn()

    set_stock = (max) ->
      $stock_prompt = $('.cart_stock_prompt').hide()
      $quantity = $('#cart_item_quantity').attr('max', 100)
      if max > 0
        $stock_prompt.find('strong').text(max).end().fadeIn()
        $quantity.prop('max', max)

    set_photo = (photo) ->
      $("#thing_photos .carousel").carousel photo

    $form.find('select#cart_item_kind_id').change ->
      $option = $(this).find("option:selected")
      $submit = $form.find('button[type="submit"]')
      set_price $option.data('price')
      set_estimated $option.data('estimated')
      set_stock $option.data('stock'), $option.data('max')
      set_photo $option.data('photo')
      if $option.val()
        $submit.removeAttr('disabled')
      else
        $submit.attr('disabled', true)

    $mobile_cart_down = $form.siblings('.mobile_cart_slidedown')
    $mobile_cart_up = $form.siblings('.mobile_cart_slideup')
    $mobile_cart_down.click ->
      $form.hide().insertAfter('#thing_actions').slideDown()
      $mobile_cart_down.hide()
      $mobile_cart_up.show()
    $mobile_cart_up.click ->
      $form.slideUp()
      $mobile_cart_down.show()
      $mobile_cart_up.hide()

Making.CartItemCreate = (cart_items_count) ->
  $form = $('#new_cart_item')
  $prompt = $form.find('.cart_prompt')

  $prompt.empty()
  $form.find('.cart_success').clone().appendTo($prompt).fadeIn()

  $('.nav_cart').popover(
    content: $form.find('.cart_success').html()
    trigger: 'manual'
    html: true
    placement: 'bottom'
  ).popover('show')
  setTimeout ->
    $('.nav_cart').popover('hide')
  , 2000

  $('.nav_cart .cart_items_count').text(cart_items_count)

Making.CartCheck = ->
  if $('.cart_item:not([disabled])').length == 0
    $('button[type="submit"]').attr('disabled', 'disabled')
  else
    $('button[type="submit"]').removeAttr('disabled')
