do (exports = window.Making || {}) ->

  exports.InitUser = ->
    if Modernizr.mq('(min-width: ' + exports.Breakpoints.screenSMMin + ')')
      $setting               = $('.vcard-setting')
      $canopy                = $('.vcard-canopy img')
      $uploadCanopyBtn       = $('#upload_canopy_btn')
      $saveUploadCanopyBtn   = $('#save_upload_canopy_btn')
      $cancelUploadCanopyBtn = $('#cancel_upload_canopy_btn')
      $selectCanopyBtn       = $('#select_canopy_btn')
      $uploadCanopyField     = $('#file')
      $uploadCanopyTip       = $uploadCanopyBtn.find('span')
      canopySize             = $canopy.attr('src').split('!')[1]

      updateCanopyRequest = (url) ->
        return $.ajax
            url: '/settings/profile'
            type: 'PATCH'
            dataType: 'json'
            data:
              user:
                canopy: url

      $uploadCanopyField
        .fileupload
          dataType: 'json'
          dropZone: null
          formData: ->
            return [{
              name: 'policy'
              value: $uploadCanopyField.attr('data-policy')
            }, {
              name: 'signature'
              value: $uploadCanopyField.attr('data-signature')
            }]
          beforeSend: (jqXHR, settings) ->
            $setting.addClass('is-working')
            $uploadCanopyBtn.disable()
            $uploadCanopyTip
              .data('tip', $uploadCanopyTip.text())
              .text('正在上传...')
            $selectCanopyBtn.addClass('is-hidden')
          done: (event, data) ->
            url = $uploadCanopyField.data('domain') + data.jqXHR.responseJSON.url

            $canopy
              .data('original', $canopy.attr('src'))
              .data('url', url)
              .attr('src', url + '!' + canopySize)
            $uploadCanopyBtn
              .addClass('is-hidden')
              .enable()
            $uploadCanopyTip.text($uploadCanopyTip.data('tip'))
            $saveUploadCanopyBtn.removeClass('is-hidden')
            $cancelUploadCanopyBtn.removeClass('is-hidden')
          fail: (event, data) ->
            $uploadCanopyBtn.enable()
            $uploadCanopyTip.text('上传失败，请重试')
            $selectCanopyBtn.removeClass('is-hidden')

      $saveUploadCanopyBtn.on 'click', (event) ->
        url = $canopy.data('url')

        if url isnt undefined and url.indexOf($uploadCanopyField.attr('data-domain')) is 0
          request = updateCanopyRequest(url)

          $saveUploadCanopyBtn
            .data('tip', $saveUploadCanopyBtn.text())
            .disable()
            .text('正在保存...')
          $cancelUploadCanopyBtn.disable()
          request
            .done (data, status, jqXHR) ->
              $saveUploadCanopyBtn
                .addClass('is-hidden')
                .enable()
                .text($saveUploadCanopyBtn.data('tip'))
              $cancelUploadCanopyBtn
                .addClass('is-hidden')
              $selectCanopyBtn.removeClass('is-hidden')
              $uploadCanopyBtn.removeClass('is-hidden')
              $setting.removeClass('is-working')
              $canopy
                .data('original', undefined)
                .data('url', undefined)
            .fail (jqXHR, status, error) ->
              $saveUploadCanopyBtn
                .enable()
                .text('保存失败，请重试')
            .always ->
              $cancelUploadCanopyBtn.enable()

      $cancelUploadCanopyBtn.on 'click', (event) ->
        $canopy
          .attr('src', $canopy.data('original'))
          .data('url', undefined)
          .data('original', undefined)
        $saveUploadCanopyBtn.addClass('is-hidden')
        $cancelUploadCanopyBtn.addClass('is-hidden')
        $selectCanopyBtn.removeClass('is-hidden')
        $uploadCanopyBtn.removeClass('is-hidden')

      exports.imagePicker
        el: '#user_canopy_picker_modal'
        after: ($activeItem, url) ->
          request = updateCanopyRequest(url)
          request
            .done (data, status, jqXHR) ->
              $canopy.attr('src', url)

      if $html.is('.users_activities:not(.users_activities_text)')
        $waterfall = $('.js-waterfall')
        waterfall  = new Masonry $waterfall[0],
          itemSelector: '.activity'

  return exports
