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
    ESC: 27
    TAB: 9
    LEFT: 37
    UP: 38
    RIGHT: 39
    DOWN: 40

  if $html.hasClass('mobile')
    exports.device = 'mobile'
  else if $html.hasClass('tablet')
    exports.device = 'tablet'
  else if $html.hasClass('desktop')
    exports.device = 'desktop'

  if window.navigator.userAgent.toLowerCase().indexOf('micromessenger') >= 0
    exports.browser = 'wechat'

  exports.infiniteScroll = (container, url = window.location.href, data, callback) ->
    $container = $(container)
    _page = 1
    _lock = false

    $window.on 'scroll.infiniteScroll', (event) ->
      if _lock or
        $document.height() - $window.scrollTop() - $window.height() > 200 then return

      data = $.extend {}, data, { page: ++_page }

      $
        .ajax
          url: url
          data: data
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
              $container.append(exports.lazyLoadImages(data))
            when 'nocontent'
              $container.append('<em class="nomore">没有更多了。</em>')
              $window.off('scroll.infiniteScroll')
          callback.call($container, data, xhr) if callback?
          _lock = false
        .fail (xhr, status, error) ->
          $container
            .children('.loading-things')
            .remove()
          .end()
            .append('<em class="nomore">出错了，请刷新后重试。</em>')
      return

    $window.trigger 'scroll.infiniteScroll' if $window.height() >= $docbody.height()

    return

  exports.selectCategories = (tags, container) ->
    cache = {}
    $(tags).find('.tags').on 'click', 'a', (event) ->
      $this = $(@)

      slug = $.trim($(@).data('slug'))

      $.ajax
        url: "/settings/interests/#{slug}"
        method: 'patch'

      if !$this.hasClass('is-active')
        if !cache[slug]
          cache[slug] = $.ajax
            url: "/things/category/#{slug}?sort_by=fanciers_count"
            dataType: 'html'
            data:
              per: 12
        cache[slug]
          .done (data, status, jqXHR) ->
            $(container).empty().append(data)

  exports.shareOnWechat = (button = '.js-share') ->
    $button = $(button)

    if exports.browser is 'wechat' and $button.length
        $tip = $('#share--wechat-tip')

        $button
          .removeAttr('data-toggle')
          .attr('href', '#')
          .on 'click', (event) ->
            event.preventDefault()
            $tip.fadeIn('fast')
        $tip
          .on 'click', (event) ->
            $(this).fadeOut('fast')

  exports.bindWechatShareTip = ->
    $tip        = $('#share--wechat-tip')
    offsetStart = 0
    offsetEnd   = 0

    $document
      .on 'scroll', (event) ->
        if $document.scrollTop() + $window.height() == $document.height()
          $tip.fadeIn('fast')
      .on 'touchstart touchmove', (event) ->
        touch = event.originalEvent.changedTouches[0]
        if event.type is 'touchstart'
          offsetStart = touch.clientY
        else
          offsetEnd = touch.clientY
          $tip.fadeOut('fast') if offsetEnd - offsetStart > 0

  exports.lazyLoadImages = (container = 'body') ->
    $container = $(container)
    $images    = $container.find('img.js-lazy')
    if $images.length
      $images
        .css('visibility', 'visible')
        .lazyload
          delay: 300
          threshold: 200
    return $container

  exports.isDebugging = ->
    Boolean(Making.GetParameterByKey('debug'))

  $ ->
    $navbar          = $('.navbar')
    $gotop           = $('#go_top')
    gotopOffsetRight = $gotop.css('right')
    scrollbarWidth   = exports.GetScrollbarWidth()

    $docbody
      .on 'freeze', ->
        $docbody.addClass('is-frozen')
        if parseInt(scrollbarWidth) > 0 and $document.height() > $window.height()
          $html.css 'margin-right', scrollbarWidth
          $navbar.css 'padding-right', scrollbarWidth
          $gotop.css 'right', "calc(#{gotopOffsetRight} + #{scrollbarWidth})"
      .on 'unfreeze', ->
        $docbody.removeClass('is-frozen')
        if parseInt(scrollbarWidth) > 0 and $document.height() > $window.height()
          $html.css 'margin-right', 0
          $navbar.css 'padding-right', 0
          $gotop.css 'right', gotopOffsetRight

  return exports
