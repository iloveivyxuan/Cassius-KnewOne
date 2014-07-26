do ($ = jQuery) ->

  if MediumEditor and typeof MediumEditor is 'function'

    # MInsert Prototype

    class MInsert

      constructor: (element, options) ->
        @$element = $(element)
        @options  = options

        @initMenu()

        @$element
          .on 'click.minsert', @toggle.bind(@)
          .on 'keyup.minsert', @toggle.bind(@)

        @$minsert
          .on 'click.minsert', '.minsert-toggle', @toggleActions.bind(@)
          .on 'click.minsert', '[data-action="insert-image"]', @insertImage.bind(@)
          .on 'click.minsert', '[data-action="insert-video"]', @insertVideo.bind(@)
          .on 'click.minsert', '[data-action="insert-embed"]', @insertEmbed.bind(@)
          .on 'click.minsert', '[data-action="insert-rule"]', @insertRule.bind(@)
          .on 'done.minsert', '[data-action="insert-image"]', @insertImageDone.bind(@)
          .on 'fail.minsert', '[data-action="insert-image"]', @insertImageFail.bind(@)

      initMenu: ->
        menu = '' +
            '<div class="minsert">' +
              '<button class="minsert-toggle" type="button">' +
                '<i class="fa fa-plus-circle"></i>' +
              '</button>' +
              '<ul class="minsert-actions">' +
                '<li>' +
                  '<button class="minsert-action" data-action="insert-image" type="button">' +
                    '<i class="fa fa-picture-o"></i>' +
                  '</button>' +
                '</li>' +
                '<li>' +
                  '<button class="minsert-action" data-action="insert-video" type="button">' +
                    '<i class="fa fa-video-camera"></i>' +
                  '</button>' +
                '</li>' +
                '<li>' +
                  '<button class="minsert-action" data-action="insert-embed" type="button">' +
                    '<i class="fa fa-code"></i>' +
                  '</button>' +
                '</li>' +
                '<li>' +
                  '<button class="minsert-action" data-action="insert-rule" type="button">' +
                    '<i class="fa fa-minus"></i>' +
                  '</button>' +
                '</li>' +
              '</ul>' +
              '<div class="minsert-input"></div>' +
            '</div>'
        @$element.after(menu)

        @$minsert            = @$element.next('.minsert')
        @$minsertActions     = @$minsert.children('.minsert-actions')
        @$minsertActionImage = @$minsertActions.find('[data-action="insert-image"]')
        @$minsertInput       = @$minsert.children('.minsert-input')

      toggle: (event) ->
        selection = window.getSelection()

        @hide()
        if selection.anchorOffset is 0
          topNode = @getTopNode(selection.anchorNode)
          if $.trim($(topNode).text()) is ''
            @insertPoint = document.createRange()
            @insertPoint.selectNode(topNode)
            @insertPoint.collapse(true)
            @show(topNode)

      show: (referenceNode) ->
        @setPosition(referenceNode)
        @$minsert.addClass('is-shown')

      hide: ->
        @$minsert.removeClass('is-shown')
        @$minsertActions.removeClass('is-shown')
        @$minsertInput.removeClass('is-shown').empty()

      getTopNode: (node) ->
        if node.parentNode.getAttribute('data-medium-element') is 'true'
          return node
        else
          return @getTopNode(node.parentNode)

      setPosition: (referenceNode) ->
        left = (@$element.offset().left - 34) + 'px'
        top  = $(referenceNode).position().top + 'px'

        @$minsert.css
          left: left
          top : top

      toggleActions: ->
        @$minsertActions.toggleClass('is-shown')
        @$minsertInput.removeClass('is-shown').empty()

      insertImage: ->
        @hide()

      insertImageDone: (event, url)->
        @insert("<img src=#{url}>")

      insertImageFail: (event) ->
        console.log 'Insert Image Fail.'
        alert('图片上传失败了，请重试。')

      insertVideo: ->
        @insertRichMedia('videos').bind(@)

      insertEmbed: ->
        @insertRichMedia('embeds').bind(@)

      insertRule: ->
        @insert('<hr>')
        @hide()

      insertRichMedia: (type) ->
        $input = $("<input type='text' placeholder=#{@options.actions[type].placeholder}>")

        $input.appendTo(@$minsertInput)
        @$minsertActions.removeClass('is-shown')
        @$minsertInput.addClass('is-shown')
        $input.focus()

        handler = (event) ->
          if event.which is 13
            content = event.target.value

            event.preventDefault()

            if content.indexOf('http') is 0
              url  = content
              html = url.replace(/\n?/g, '')
                .replace(/^((http(s)?:\/\/)?(www\.)?(youtube\.com|youtu\.be)\/(watch\?v=|v\/)?)([a-zA-Z0-9-_]+)(.*)?$/, '<div class="video"><iframe width="420" height="315" src="//www.youtube.com/v/$7&amp;fs=1" frameborder="0" allowfullscreen></iframe></div>')
                .replace(/http:\/\/vimeo\.com\/(\d+)$/, '<iframe src="//player.vimeo.com/video/$1" width="500" height="281" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>')
                .replace(/^http:\/\/v\.youku.com\/v_show\/id_(.+)(\.html){1}(.*)/, '<iframe height=498 width=510 src="http://player.youku.com/embed/$1" frameborder=0 allowfullscreen></iframe>')
                .replace(/^http:\/\/www\.tudou\.com\/listplay\/([a-zA-Z0-9]+)\/([a-zA-Z0-9]+)\.html$/, '<iframe src="http://www.tudou.com/programs/view/html5embed.action?type=1&code=$2&lcode=$1&resourceId=0_06_05_99" allowtransparency="true" scrolling="no" border="0" frameborder="0" style="width:480px;height:400px;"></iframe>')
                .replace(/^http:\/\/www\.tudou\.com\/programs\/view\/(.+)$/, '<iframe src="http://www.tudou.com/programs/view/html5embed.action?type=0&code=$1" allowtransparency="true" scrolling="no" border="0" frameborder="0" style="width:480px;height:400px;"></iframe>')
                .replace(/^http:\/\/www\.56\.com\/(.+)\/v_(.+)\.html$/, '<iframe width="480" height="405" src="http://www.56.com/iframe/$2" frameborder="0" allowfullscreen=""></iframe>')
                .replace(/^http:\/\/v\.qq\.com\/page\/(.+)\/(.+)\/(.+)\/([a-zA-Z0-9]+)\.html$/, '<iframe width="480" height="405" frameborder=0 src="http://v.qq.com/iframe/player.html?vid=$4&tiny=0&auto=0" allowfullscreen></iframe>')
                .replace(/https:\/\/twitter\.com\/(\w+)\/status\/(\d+)\/?$/, '<blockquote class="twitter-tweet" lang="en"><a href="https://twitter.com/$1/statuses/$2"></a></blockquote><script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>')
                .replace(/https:\/\/www\.facebook\.com\/(\w+)\/posts\/(\d+)$/, '<div id="fb-root"></div><script>(function(d, s, id) { var js, fjs = d.getElementsByTagName(s)[0]; if (d.getElementById(id)) return; js = d.createElement(s); js.id = id; js.src = "//connect.facebook.net/en_US/all.js#xfbml=1"; fjs.parentNode.insertBefore(js, fjs); }(document, "script", "facebook-jssdk"));</script><div class="fb-post" data-href="https://www.facebook.com/$1/posts/$2"></div>')
                .replace(/http:\/\/instagram\.com\/p\/(.+)\/?$/, '<span class="instagram"><iframe src="//instagram.com/p/$1/embed/" width="612" height="710" frameborder="0" scrolling="no" allowtransparency="true"></iframe></span>')
              if /<("[^"]*"|'[^']*'|[^'">])*>/.test(html) then content = html

            @insert(content)
        $input.on 'keydown.minsert', handler.bind(@)

      insert: (html) ->
        selection = window.getSelection()

        selection.removeAllRanges()
        selection.addRange(@insertPoint)
        document.execCommand('insertHTML', false, html)

    MInsert.DEFAULTS =
      actions:
        images: {}
        videos:
          placeholder: '在这里插入视频网址或代码'
        embeds:
          placeholder: '在这里插入网址或代码'
        rules : {}

    # MInsert jQuery Plugin Definition

    $.fn.minsert = (option) ->

      return @each ->
        $this   = $(this)
        data    = $this.data('minsert')
        options = $.extend(
                    {},
                    MInsert.DEFAULTS,
                    typeof option is 'object' and option
                  )

        if !data then $this.data 'minsert', (data = new MInsert(this, options))
        if typeof option is 'string' then data[option]()

        return

    return
