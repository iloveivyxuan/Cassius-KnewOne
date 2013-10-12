Making.OrderPage =
  InitNew: ->
    $ ->
      $('.deliver_method').on('change',
      ->
        price = parseFloat($(this).attr('data-price')) + parseFloat($('.total_price').attr('data-things-price'))
        $('.total_price').text('￥' + price.toFixed(2))
      )

      $('.make-order').click(
        ->
          $('#new_order').submit()
      )

      $('.addresses').on('click', '.order_address_radio',
      ->
        $('#order_address_id').val($(this).val())
      )

      if($('.order_address_radio').length == 0)
        $('.order_address_id').on('change',
        ->
          $('.make-order').removeAttr("disabled")
        )
        $('.make-order').attr("disabled", "disabled")
        $('.new_address_btn').click()
      else
        $('.order_address_radio').last().click()
