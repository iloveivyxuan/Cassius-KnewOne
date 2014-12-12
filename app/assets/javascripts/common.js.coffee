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

  if window.navigator.userAgent.toLowerCase().indexOf('micromessenger') >= 0
    exports.browser = 'wechat'

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
          _lock = false
        .fail (xhr, status, error) ->
          $container
            .children('.loading-things')
            .remove()
          .end()
            .append('<em class="nomore">出错了，请刷新后重试。</em>')
      return
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

  exports.shareOnWechat = ->
    $button = $('.js-share')

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

  exports.loadEmbed = ->
    $embed     = $(".knewone-embed:empty")
    requestUrl = "http://#{location.host}/embed"
    $embed.each (index, element) ->
      $element = $(element)
      requestData =
        type: $element.data('knewoneEmbedType')
        key: $element.data('knewoneEmbedKey') or $element.data('knewoneEmbedId')
      if $element.data('knewoneEmbedOptions')
        requestData['options'] = $element.data('knewoneEmbedOptions')
      $
        .ajax
          url: requestUrl
          data: requestData
          dataType: 'html'
          beforeSend: ->
            $element.append('<div class="spinner"><i class="fa fa-spinner fa-2x fa-spin"></i></div>')
        .done (data, status, xhr) ->
          $element
            .empty()
            .append(data)
            .attr('contenteditable', false)
        .fail (xhr, status, error) ->
          $element
            .empty()
            .append('<p class="knewone-embed-tip">无效的资源。</p>')
            .attr('contenteditable', false)

  exports.lazyLoadImages = (container = 'body') ->
    $container = $(container)
    $images    = $container.find('img.js-lazy')
    if $images.length
      $images
        .css('visibility', 'visible')
        .lazyload
          threshold: 200
    return $container

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
