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

      if($('[name^="order[address_id]"]:enabled').length == 0)
        $('.make_order').attr("disabled", "disabled")

      $('.order_coupon_radio').click(
        ->
          window.location.href = $(@).attr("data-href")
      )

      requireAddress = (required) ->
        $(['#order_address_province_code'
           '#order_address_city_code'
           '#order_address_district_code'
           '#order_address_street'
           '#order_address_name'
           '#order_address_phone'].join(', ')).prop('required', required)

      $('[name="order[address_id]"]').on('change', ->
        required = $('#order_address_id_new').prop('checked')
        requireAddress(required)
      )

      $('[name^="order[address]"]').on('focus', ->
        $('#order_address_id_new').prop('checked', true)
        requireAddress(true)
      )

      $('[name^="order[address_id]"]:enabled').first().prop('checked', true)
