Making.OrderPage =
  InitNew: ->
    $ ->
      $('.use_sf').on('change',
      ->
        price = parseFloat($('.total_price').attr('data-things-price')) + \
                parseFloat($('.total_price').attr('data-rebates-price'))

        if $(@).prop('checked')
          price += parseFloat($(this).attr('data-price'))

        price = 0 if price < 0
        $('.total_price strong span').text(price.toFixed(1))
      )

      if($('.order_address_radio').length == 0)
        $('.order_address_id').on('change',
        ->
          $('.make_order').removeAttr("disabled")
        )
        $('.make_order').attr("disabled", "disabled")

      $('.order_coupon_radio').click(
        ->
          window.location.href = $(@).attr("data-href")
      )
