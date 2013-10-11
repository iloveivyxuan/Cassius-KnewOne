Making.CartItemNew = ->
  $ ->
    $form = $('#new_cart_item')

    $form.find('.kind a').click ->
      $this = $(@)
      $('.shop .price small').text "￥ #{$this.data('price')}"
      $form.find('.selected').removeClass('selected')
      $prompt = $form.find('.cart_prompt')
      prompt = (selector) ->
        $this.parent().find(selector).clone()
        .appendTo($prompt)
        .hide().removeClass('hidden').fadeIn()
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

Making.CartItemPage =
  InitIndex: ->
    $('.item_quantity').blur(
      ->
        Making.CartItemPage.RefreshSingleItemPrice($(@).closest('.cart_item'))
        Making.CartItemPage.RefreshTotalItemPrice()
    )
    $('.cart_item').each(
      ->
        Making.CartItemPage.RefreshSingleItemPrice($(@))
    )
    Making.CartItemPage.RefreshTotalItemPrice()

  RefreshSingleItemPrice: ($item) ->
    total_price = Making.CartItemPage.CalculateSingleItemPrice($item.find('.item_quantity').val(),
      $item.find('.price').attr('data-price'))
    $item.find('.price').text(Making.CartItemPage.WrapPrice(total_price)).attr('data-total', total_price)

  RefreshTotalItemPrice: ->
    total_price = 0.00
    $('.cart_item .price').each(
      ->
        total_price += parseFloat($(@).attr('data-total'))
    )
    $('.total_price').text(Making.CartItemPage.WrapPrice(total_price))

  CalculateSingleItemPrice: (quantity, price) ->
    parseFloat(quantity) * parseFloat(price)

  WrapPrice: (price) ->
    "￥ #{price.toFixed(2)}"
