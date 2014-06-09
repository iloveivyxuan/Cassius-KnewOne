Making.Views.Share = Backbone.View.extend

  el: '.share'

  events:
    'mouseenter .weixin': 'weixin'
    'mouseleave .weixin': 'weixin'
    'click .weixin': 'prevent_default'
    'click .weibo': 'weibo'
    'click .twitter': 'twitter'

  initialize: ->
    @$weixin = @$('.weixin')
    @$weixin.popover
      html: true
      content: $('<div />').qrcode
        render: 'image'
        ecLevel: 'L'
        text: document.URL

  prevent_default: (event) ->
    event.preventDefault()

  weixin: (event) ->
    @$weixin.popover if event.type is 'mouseenter' then 'show' else 'hide'

  weibo: (event) ->
    event.preventDefault()
    content = $('meta[name="sharing_content"]').attr('content')
    if content == undefined or content.length == 0 then content = location.href
    window.open 'http://v.t.sina.com.cn/share/share.php?title=' + encodeURIComponent(content) + '&amp;url=' + encodeURIComponent(location.href) + '&amp;source=bookmark' + '&amp;content=utf-8', '_blank', 'width=500,height=500'

  twitter: (event) ->
    event.preventDefault()
    window.open 'http://twitter.com/share?url=' + encodeURIComponent(location.href) + '&amp;source=bookmark', '_blank', 'width=500,height=500'
