window.CartItemPage =
  InitKindSelect: ->
    $ ->
      $('.kind-select').click(
        ->
          $this = $(@)
          $('.cart_item_kind_id').val($this.attr('data-kind-id'))
          $('.kind > .kind-select').removeClass('selected')
          $('.cart_item_quantity').prop('max', $this.attr('data-stock'))
          $('.buy .price small').text('￥ ' + $this.attr('data-price'))
          $('.buy span.kind-stock').text('库存' + $this.attr('data-stock') + '件')
          $('.buy .estimate-info').html($this.children('.estimates_at').html())
          $this.addClass('selected')
      ).first().trigger('click')

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
