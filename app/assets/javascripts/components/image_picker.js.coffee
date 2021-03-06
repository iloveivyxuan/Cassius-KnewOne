do (exports = Making) ->

  exports.imagePicker = (options) ->
    $imagePicker = $(options.el)

    $imagePicker.on 'click', '.image_picker-item', (event) ->
      $activeItem = $(this)
      url         = $activeItem.data('url')

      event.preventDefault()

      $activeItem
        .addClass('is-active')
      .siblings()
        .removeClass('is-active')

      options.after.call($imagePicker, $activeItem, url) if options.after

  return exports
