Making.OrderPage =
  InitNew: ->
    $ ->
      $('.deliver_method').on('change',
      ->
        price = parseFloat($(this).attr('data-price')) + parseFloat($('.total_price').attr('data-things-price'))
        $('.total_price strong span').text(price.toFixed(2))
      )

      if($('.order_address_radio').length == 0)
        $('.order_address_id').on('change',
        ->
          $('.make_order').removeAttr("disabled")
        )
        $('.make_order').attr("disabled", "disabled")
      else
        $('.order_address_radio').last().click()
