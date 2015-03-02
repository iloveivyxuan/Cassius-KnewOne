do (exports = window.Making || {}) ->

  exports.InitUser = ->
    if Modernizr.mq('(min-width: ' + exports.Breakpoints.screenSMMin + ')')
      $action            = $('.vcard-action')
      $canopy            = $('.vcard-canopy img')
      $uploadCanopyBtn   = $('#upload_canopy_btn')
      $selectCanopyBtn   = $('#select_canopy_btn')
      $uploadCanopyField = $('#file')
      $uploadCanopyTip   = $uploadCanopyBtn.find('span')
      canopySize         = $canopy.attr('src').split('!')[1]

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
            $action.addClass('is-working')
            $uploadCanopyTip
              .data('tip', $uploadCanopyTip.text())
              .text('正在上传...')
            $uploadCanopyBtn.disable()
            $selectCanopyBtn.disable()
          done: (event, data) ->
            url = $uploadCanopyField.data('domain') + data.jqXHR.responseJSON.url

            $canopy
              .attr('src', url + '!' + canopySize)
              .data('url', url)
            $uploadCanopyBtn
              .enable()
              .addClass('is-standby')
            $uploadCanopyTip.text('保存背景')
          fail: (event, data) ->
            $uploadCanopyBtn.enable()
            $uploadCanopyTip.text('上传失败，请重试')
            $selectCanopyBtn.enable()

      $uploadCanopyBtn.on 'click', (event) ->
        url = $canopy.data('url')

        if $uploadCanopyBtn.hasClass('is-standby') and url isnt undefined and url.indexOf($uploadCanopyField.attr('data-domain')) is 0
          request = updateCanopyRequest(url)

          $uploadCanopyBtn.disable()
          request
            .done (data, status, jqXHR) ->
              $uploadCanopyTip.text($uploadCanopyTip.data('tip'))
              $action.removeClass('is-working')
            .fail (jqXHR, status, error) ->
              $uploadCanopyTip.text('更新失败，请重试')
            .always ->
              $canopy.data('url', undefined)
              $uploadCanopyBtn
                .enable()
                .removeClass('is-standby')
              $selectCanopyBtn.enable()

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
