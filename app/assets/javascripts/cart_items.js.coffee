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
      false

    $form.find('.kind a.select_disabled').click ->
      $form.find('button[type="submit"]').attr('disabled', 'disabled')

    $form.find('.kind a.select_enabled').click(->
      $form.find('#cart_item_kind_id').val $(@).data('id')
      $form.find('#cart_item_quantity').prop 'max', $(@).data('stock')
      $(@).addClass('selected')
      $form.find('button[type="submit"]').removeAttr('disabled')
    ).first().trigger('click')

    $form.siblings('.mobile_cart_trigger').click ->
      $form.hide().appendTo('#thing_actions').slideDown()

Making.CartItemCreate = (cart_items_count) ->
  $form = $('#new_cart_item')
  $prompt = $form.find('.cart_prompt')

  $prompt.empty()
  $form.find('.cart_success').clone().appendTo($prompt).fadeIn()
  $('.nav_cart .cart_items_count').text(cart_items_count)

window.CartItemPage =
  InitIndex: ->
    $('.item_quantity').blur(
      ->
        CartItemPage.RefreshSingleItemPrice($(@).closest('.cart_item'))
        CartItemPage.RefreshTotalItemPrice()
    )
    $('.cart_item').each(
      ->
        CartItemPage.RefreshSingleItemPrice($(@))
    )
    CartItemPage.RefreshTotalItemPrice()

  RefreshSingleItemPrice: ($item) ->
    total_price = CartItemPage.CalculateSingleItemPrice($item.find('.item_quantity').val(),
      $item.find('.price').attr('data-price'))
    $item.find('.price').text(CartItemPage.WrapPrice(total_price)).attr('data-total', total_price)

  RefreshTotalItemPrice: ->
    total_price = 0.00
    $('.cart_item .price').each(
      ->
        total_price += parseFloat($(@).attr('data-total'))
    )
    $('.total_price').text(CartItemPage.WrapPrice(total_price))

  CalculateSingleItemPrice: (quantity, price) ->
    parseFloat(quantity) * parseFloat(price)

  WrapPrice: (price) ->
    "￥ #{price.toFixed(2)}"
