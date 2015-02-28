do (exports = window.Making || {}) ->

  exports.InitUser = ->
    if Modernizr.mq('(min-width: ' + exports.Breakpoints.screenSMMin + ')')
      $canopy            = $('.vcard-canopy img')
      $uploadCanopyBtn   = $('#upload_canopy_btn')
      $selectCanopyBtn   = $('#select_canopy_btn')
      $uploadCanopyField = $('#file')
      $uploadCanopyTip   = $uploadCanopyBtn.find('span')
      canopySize         = $canopy.attr('src').split('!')[1]

      updateCanopyRequest = (url) ->
        return $.ajax
            url: "#{window.location.origin}/users/#{exports.user}/set_profile"
            type: 'POST'
            data:
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
            $uploadCanopyTip
              .data('tip', $uploadCanopyTip.text())
              .text('正在上传...')
            $uploadCanopyBtn.disable()
            $selectCanopyBtn.disable()
          done: (event, data) ->
            url = $uploadCanopyField.data('domain') + data.jqXHR.responseJSON.url
            request = updateCanopyRequest(url)
            request
              .done (data, status, jqXHR) ->
                $canopy.attr('src', url + '!' + canopySize)
                $uploadCanopyBtn.enable()
                $selectCanopyBtn.enable()
                $uploadCanopyTip.text($uploadCanopyTip.data('tip'))
              .fail (jqXHR, status, error) ->
                $uploadCanopyBtn.enable()
                $selectCanopyBtn.enable()
                $uploadCanopyTip.text('更新失败，请重试')
          fail: (event, data) ->
            $uploadCanopyBtn.enable()
            $selectCanopyBtn.enable()
            $uploadCanopyTip.text('上传失败，请重试')

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
