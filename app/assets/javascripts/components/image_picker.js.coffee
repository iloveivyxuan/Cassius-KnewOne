do (exports = Making) ->

  exports.imagePicker = (options) ->
    $imagePicker = $(options.el)

    $imagePicker.on 'click', '.image_picker-item', (event) ->
      $item = $(this)
      url   = $item.data('url')

      event.preventDefault()

      $item
        .addClass('is-actived')
      .siblings()
        .removeClass('is-actived')

      options.after.call($imagePicker, url) if options.after

  return exports
