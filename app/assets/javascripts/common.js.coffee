do (root = @, exports = Making) ->

  # TODO
  if !window.location.origin
    window.location.origin = window.location.protocol +
      "//" +
      window.location.hostname +
      (if window.location.port then ':' + window.location.port else '')

  exports.url  = window.location.origin + window.location.pathname
  exports.user = $('#user').data('id')

  exports.Breakpoints =
    "screenXSMin": "480px"
    "screenXSMax": "767px"
    "screenSMMin": "768px"
    "screenSMMax": "991px"
    "screenMDMin": "992px"
    "screenMDMax": "1439px"
    "screenLGMin": "1440px"
    "screenLGMax": "1919px"
    "screenXLMin": "1920px"

  exports.keycode =
    ENTER: 13

  if $html.hasClass('mobile')
    exports.device = 'mobile'
  else if $html.hasClass('tablet')
    exports.device = 'tablet'
  else if $html.hasClass('desktop')
    exports.device = 'desktop'

  exports.infiniteScroll = (container, url, callback) ->
    $container = $(container)
    _page = 1
    _lock = false

    $window.on 'scroll.infiniteScroll', (event) ->
      if _lock or
        $document.height() - $window.scrollTop() - $window.height() > 200 then return

      $
        .ajax
          url: url
          data:
            page: ++_page
          dataType: 'html'
          beforeSend: (xhr, settings) ->
            _lock = true
            $container.append("" +
              "<div class='loading-things'>" +
                "<i class='fa fa-spinner fa-spin fa-2x'></i>" +
              "</div>")
        .done (data, status, xhr) ->
          $container
            .children('.loading-things')
            .remove()
          switch status
            when 'success'
              $container.append(data)
            when 'nocontent'
              $container.append('<em class="nomore">没有更多了。</em>')
              $window.off('scroll.infiniteScroll')
          callback.call($container, data, xhr) if callback?
        .fail (xhr, status, error) ->
          $container
            .children('.loading-things')
            .remove()
          .end()
            .append('<em class="nomore">出错了，请刷新后重试。</em>')
        .always ->
          _lock = false
      return
    return

  exports.scrollSpyPopupLogin = (redirectFrom, pixelsFromTopToBottom = -100) ->
    if exports.user? then return

    $window.on 'scroll.login', ->
      if pixelsFromTopToBottom >= 0
        isFire = $window.scrollTop() >= pixelsFromTopToBottom
      else
        isFire = $document.height() - $window.scrollTop() - $window.height() <= -pixelsFromTopToBottom

      if isFire
        switch exports.device
          when 'mobile', 'tablet'
            $('#header [data-target="#login-modal"]').trigger('click')
          when 'desktop'
            $('#header .user_link[data-target="#login-modal"]').trigger('click')
        $('#login-modal').find('[name="redirect_from"]').val(redirectFrom)
        $window.off 'scroll.login'

  return exports
