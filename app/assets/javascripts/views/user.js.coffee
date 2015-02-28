do (exports = window.Making || {}) ->

  exports.InitUser = ->
    if Modernizr.mq('(min-width: ' + exports.Breakpoints.screenSMMin + ')')
      $canopy            = $('.vcard-canopy img')
      $uploadCanopyBtn   = $('#upload_canopy_btn')
      $uploadCanopyField = $('#file')
      $uploadCanopyTip   = $uploadCanopyBtn.find('span')

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
          done: (event, data) ->
            url = $uploadCanopyField.data('domain') + data.jqXHR.responseJSON.url
            version = $canopy.attr('src').split('!')[1]

            $
              .ajax
                url: "#{window.location.origin}/users/#{exports.user}/set_profile"
                type: 'POST'
                data:
                  canopy: url
              .done (data, status, jqXHR) ->
                $canopy.attr('src', url + '!' + version)
                $uploadCanopyBtn.enable()
                $uploadCanopyTip.text($uploadCanopyTip.data('tip'))
              .fail (jqXHR, status, error) ->
                $uploadCanopyBtn.enable()
                $uploadCanopyTip.text('更新失败，请重试')
          fail: (event, data) ->
            $uploadCanopyBtn.enable()
            $uploadCanopyTip.text('上传失败，请重试')

      if $html.is('.users_activities:not(.users_activities_text)')
        $waterfall = $('.js-waterfall')
        waterfall  = new Masonry $waterfall[0],
          itemSelector: '.activity'

  return exports
