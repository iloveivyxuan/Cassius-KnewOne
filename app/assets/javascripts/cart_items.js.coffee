Making.CartItemNew = ->
  $ ->
    $form = $('#new_cart_item')
    $prompt = $form.find('.cart_prompt')

    $form.find('.kind a').click ->
      $this = $(@)
      $('.shop .price small').text "￥ #{$this.data('price')}"
      $form.find('.selected').removeClass('selected')
      prompt = (selector) ->
        $this.parent().find(selector).clone()
          .appendTo($prompt)
          .fadeIn()
      $prompt.empty()
      prompt '.estimates_at'
      prompt '.stock'
      $("#photo_main.carousel").carousel $this.data('photo')
      false

    $form.find('.kind a.select_disabled').click ->
      $form.find('button[type="submit"]').attr('disabled', 'disabled')

    $form.find('.kind a.select_enabled').click ->
      $form.find('#cart_item_kind_id').val $(@).data('id')
      $form.find('#cart_item_quantity').prop 'max', $(@).data('stock')
      $(@).addClass('selected')
      $form.find('button[type="submit"]').removeAttr('disabled')

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
  $('.cart_link').popover(
    content: $form.find('.cart_success').html()
  ).popover('show')
  setTimeout(
    ->
      $('.cart_link').popover('hide')
    , 2000
  )
  $('.nav_cart .cart_items_count').text(cart_items_count)
