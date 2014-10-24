Making.CartItemNew = ->
  $ ->
    if Modernizr.mq('(max-width: ' + Making.Breakpoints.screenSMMax + ')')
      $('#thing_actions').remove()
    else if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenMDMin + ')')
      $('#thing_actions_compact').remove()

    $form = $('#new_cart_item')
    $submit = $form.find('button[type="submit"]')
    $price = $('#price')
    $quantity = $form.find('.cart_item_quantity').children('input[type="number"]')
    thing_price = $price.text()

    set_price = (price) ->
      $price.html (price or thing_price)

    set_estimated = (estimated) ->
      $prompt = $('.cart_estimated_prompt').hide()
      if estimated
        $prompt.find('time').replaceWith(estimated).end().show()

    set_stock = (max) ->
      $stock_prompt = $('.cart_item_quantity .help-block').hide()
      $quantity = $('#cart_item_quantity').attr('max', 100)
      if max > 0
        $stock_prompt.find('strong').text(max).end()
          .css('display', 'inline-block')
        $quantity.prop('max', max)

    set_photo = (photo) ->
      $("#thing_photos .carousel").carousel photo

    $form.find('select#cart_item_kind_id').change ->
      $option = $(@).find('option:selected')
      set_price $option.data('price')
      set_estimated $option.data('estimated')
      set_stock $option.data('max')
      set_photo $option.data('photo')
      if $option.val()
        $quantity.removeAttr('disabled')
        $submit.removeAttr('disabled')
        $(@).find('option').filter (index) ->
          return index is 0 and @.value is '' and !$(@).attr('disabled')
        .attr('disabled', true)
      else
        $quantity.attr('disabled', true)
        $submit.attr('disabled', true)

    $('#mobile_buy_modal').on 'show.bs.modal', (e) ->
      $form = $form.find('button[type="submit"]').remove().end()
      $modal = $('#mobile_buy_modal .modal-body').empty()
      $form.appendTo($modal).removeClass('hidden').show()
      $('#mobile_buy_modal .modal-footer .buy_button').click ->
        $form.trigger('submit')
        $('#mobile_buy_modal').modal('hide')

    $kind_options = $form.find('option.kind_option:enabled')
    if $kind_options.length
      $kind_options.first().prop('selected', true).parent().trigger('change')

Making.CartItemCreate = (cart_items_count) ->
  $success = $('#new_cart_item .cart_success').show()
  if $('.navbar-toggle').is(':visible')
    $cart = $('.navbar-toggle')
  else
    $cart = $('.navbar .cart')

  $cart.popover(
    content: $success[0].outerHTML
    trigger: 'manual'
    html: true
    placement: 'bottom'
  ).popover('show')

  setTimeout ->
    $cart.popover('hide')
  , 5000

  $('.navbar .cart .cart_items_count').text(cart_items_count)

Making.CartCheck = ->
  if $('.cart_item:not([disabled])').length == 0
    $('button[type="submit"]').attr('disabled', true)
  else
    $('button[type="submit"]').removeAttr('disabled')
