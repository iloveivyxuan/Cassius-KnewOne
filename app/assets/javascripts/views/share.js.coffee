Making.Views.Share = Backbone.View.extend

  el: '.share'

  events:
    'mouseenter .weixin': 'weixin'
    'click .weibo': 'weibo'
    'click .twitter': 'twitter'

  initialize: ->
    @$weixin = @$('.weixin')

  weixin: (event) ->
    event.preventDefault()

    @$weixin.popover
      html: true
      content: $('<div />').qrcode
        render: 'image'
        ecLevel: 'L'
        text: document.URL

  weibo: (event) ->
    event.preventDefault()
    window.open 'http://v.t.sina.com.cn/share/share.php?title=' + encodeURIComponent(document.title) + '&amp;url=' + encodeURIComponent(location.href) + '&amp;source=bookmark', '_blank', 'width=500,height=500'

  twitter: (event) ->
    event.preventDefault()
    window.open 'http://twitter.com/share?url=' + encodeURIComponent(location.href) + '&amp;source=bookmark', '_blank', 'width=500,height=500'
