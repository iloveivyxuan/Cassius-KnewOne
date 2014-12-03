do (exports = Making) ->

  exports.embedThing = (element) ->
    $element       = $(element)
    $modal         = $('#thing--embed_form')
    $submit        = $modal.find('.js-submit')
    $photoFieldset = $modal.find('.fieldset--photo')
    $photoPreview  = $photoFieldset.children('figure')
    $photoButton   = $photoFieldset.children('footer').children('button')
    $photoField    = $photoFieldset.find('input[type="file"]')
    photoUrl       = ''
    articleId      = $element.attr('data-article-id') || $element.find('.article').attr('data-article-id')

    $element
      .on 'mouseenter.embed', '.thing--embed', (event) ->
        $(event.currentTarget)
          .append('' +
            '<button class="knewone-embed-edit" type="button" data-toggle="modal" data-target="#thing--embed_form">' +
            '<i class="fa fa-pencil"></i>' +
          '</button>')
      .on 'mouseleave.embed', '.thing--embed', (event) ->
        $(event.currentTarget)
          .children('.knewone-embed-edit')
          .remove()
      .on 'click.embed', '.knewone-embed-edit', (event) ->
        $modal.data('embedEditTarget', $(@).parent())

    $modal
      .on 'click', '.js-submit', (event) ->
        $editTarget  = $modal.data('embedEditTarget')
        $embed       = $editTarget.closest('.knewone-embed--thing')
        embedOptions = JSON.parse($embed.attr('data-knewone-embed-options') || '{}')
        photos        = if Array.isArray(embedOptions['photos']) then embedOptions['photos'] else (if embedOptions['photos'] then new Array(embedOptions['photos']) else [])
        index         = $editTarget.index()
        photos[index] = photoUrl
        embedOptions['photos'] = photos.join(',')
        $embed.attr('data-knewone-embed-options', JSON.stringify(embedOptions))
        $editTarget
          .children('a')
          .children('img')
          .attr('src', photoUrl + '!middle')
        $element.trigger('input')
        $modal.modal('hide')
        $photoPreview.empty()

    $photoField
      .removeAttr('id')
      .attr('accept', 'image/*')
      .fileupload
        dataType: 'json'
        dropZone: null
        formData: ->
          return [{
            name: 'policy'
            value: $photoField.attr('data-policy')
          }, {
            name: 'signature'
            value: $photoField.attr('data-signature')
          }]
        beforeSend: (jqXHR, settings) ->
          $photoButton.button('loading')
        done: (event, data) ->
          photoUrl = $photoField.data('domain') + data.jqXHR.responseJSON.url
          $photoPreview
            .empty()
            .append("<img src=#{photoUrl}>")
          $photoButton.button('reset')
          $submit.enable()

  return exports
