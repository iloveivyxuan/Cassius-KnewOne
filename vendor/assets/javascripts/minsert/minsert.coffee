do ($ = jQuery) ->

  if MediumEditor and typeof MediumEditor is 'function'

    # MInsert Prototype

    class MInsert

      constructor: (element, options) ->
        @$element = $(element)
        @options  = options

        @initMenu()

        @$element
          .one 'click.minsert', @setMenuLeftPosition.bind(@)
          .one 'keydown.minsert', @setMenuLeftPosition.bind(@)
          .on 'click.minsert', @toggle.bind(@)
          .on 'keyup.minsert', @toggle.bind(@)
          .on 'click.minsert', 'img', @handleFigureFocus.bind(@)
          .on 'keypress.minsert', @linefeed.bind(@)
          .on 'copy.minsert', @copy.bind(@)
          .on 'cut.minsert', @cut.bind(@)
          .on 'paste.minsert', @paste.bind(@)
          .on 'loading.minsert', @loading.bind(@)
          .on 'loaded.minsert', @loaded.bind(@)
          .on 'done:image.minsert', @insertImageDone.bind(@)
          .on 'fail:image.minsert', @insertImageFail.bind(@)

        @$minsert
          .on 'click.minsert', '.minsert-toggle', @toggleActions.bind(@)
          .on 'click.minsert', '[data-action="insert-image"]', @insertImage.bind(@)
          .on 'click.minsert', '[data-action="insert-video"]', @insertVideo.bind(@)
          .on 'click.minsert', '[data-action="insert-embed"]', @insertEmbed.bind(@)
          .on 'click.minsert', '[data-action="insert-rule"]', @insertRule.bind(@)

        $document
          .on 'click.minsert keypress.minsert', @handleFigureBlur.bind(@)

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
        target    = event.target

        @hide()
        if target.nodeName is 'IMG'
          parentNode = target.parentNode
          if parentNode.nodeName is 'FIGURE' or $(parentNode).css('display') is 'block'
            @insertPoint  = document.createRange()
            @insertPoint.selectNode(parentNode)
            selection.removeAllRanges()
            selection.addRange(@insertPoint)
            if event.type is 'click'
              @preClipboard = parentNode
        else if selection.anchorOffset is 0 and @$element.text().trim().length > 0
          anchorNode = selection.anchorNode
          if anchorNode.textContent.trim() is ''
            @insertPoint = document.createRange()
            @insertPoint.selectNode(anchorNode)
            @insertPoint.collapse(true)
            @show(anchorNode)

      show: (referenceNode) ->
        @setMenuTopPosition(referenceNode)
        @$minsert.addClass('is-shown')

      hide: ->
        @$minsert.removeClass('is-shown')
        @$minsertActions.removeClass('is-shown')
        @$minsertInput.removeClass('is-shown').empty()

      getTopNode: (node) ->
        if node.parentNode.getAttribute('data-medium-element') is 'true'
          return node
        else
          if node.parentNode?
            return @getTopNode(node.parentNode)
          else
            return false

      setMenuLeftPosition: ->
        left = (@$element.offset().left - 34) + 'px'
        @$minsert.css('left', left)

      setMenuTopPosition: (referenceNode) ->
        if @$element.css('position') isnt 'static'
          top = $(referenceNode).offset().top + 'px'
        else
          top = $(referenceNode).position().top + 'px'
        @$minsert.css('top', top)

      toggleActions: ->
        @$minsertActions.toggleClass('is-shown')
        @$minsertInput.removeClass('is-shown').empty()

      loading: (event, id) ->
        # @TODO
        # @insert("<progress id=#{id} class='minsert-progress'></progress>")
        @insert("<div class='progress minsert-progress' id='minsert-progress-#{id}'>
          <div class='progress-bar progress-bar-striped active' role='progressbar' aria-valuemin='0' aria-valuemax='100' style='width: 100%'>
          </div>
        </div>")

      loaded: (event, id) ->
        # @TODO
        # @$element.find("progress##{id}").remove()
        @$element.find("#minsert-progress-#{id}").remove()

      handleFigureFocus: (event) ->
        $figure = $(event.target).parent()
        if !$figure.hasClass('is-focused')
          $figure.addClass('is-focused')

      handleFigureBlur: (event) ->
        if event.type is 'click'
          $target = $(event.target)
          @$element.find('.is-focused').removeClass('is-focused')
          # @TODO
          if $target.closest('.editor-content').length and
            $target.is('img') and
            !$target.parent().hasClass('is-focused')
              $target.parent().addClass('is-focused')
        else if event.type is 'keypress' and !event.metaKey and !event.ctrlKey
          @$element.find('.is-focused').removeClass('is-focused')
          @preClipboard = null

      linefeed: (event) ->
        if event.which is 13
          if @preClipboard
            event.preventDefault()
            selection = window.getSelection()
            p         = document.createElement('p')
            p.innerHTML = '<br>'
            @insertPoint.collapse(false)
            @insertPoint.insertNode(p)
            selection.removeAllRanges()
            selection.addRange(@insertPoint)
            selection.collapseToStart()

      insertImage: ->
        @hide()

      insertImageDone: (event, data)->
        # @TODO
        # @insert("<figure><img src=#{url}></figure>")
        url = data.url
        id  = data.id
        @insert("<p><img src=#{url}></p>", id)

      insertImageFail: (event, message) ->
        alert(message ? '图片上传失败了，请重试。')

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
            content = event.target.value.trim()

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
            else if content.indexOf('<iframe') is 0 and !$(content).attr('src')
              content = ''

            @insert(content)
            @hide()
        $input.on 'keydown.minsert', handler.bind(@)

      insert: (content, id) ->
        $node = $('<p>').html(content)

        if $node.children().length > 0
          $node = $node.contents().unwrap()
          if id?
            range = document.createRange()
            range.selectNode(document.querySelector('#minsert-progress-' + id))
            range.collapse(true)
            range.insertNode($node[0])
          else
            @insertPoint.insertNode($node[0])
        else
          p = document.createElement('p')
          p.innerHTML = content
          console.log 'bar:' + id
          if id?
            range = document.createRange()
            range.selectNode(document.querySelector('#minsert-progress-' + id))
            range.collapse(true)
            range.insertNode(p)
          else
            @insertPoint.insertNode(p)
        @$element.trigger('input')

      # @TODO
      clearClipboard: (event) ->
        if event.originalEvent.clipboardData
          event.originalEvent.clipboardData.setData('text/plain', '')
        else if window.clipboardData
          window.clipboardData.setData('text', '')

      copy: (event) ->
        if @preClipboard
          event.preventDefault()
          @clearClipboard(event)
          @clipboard = @preClipboard
          @preClipboard = null
          return false
        else
          @preClipboard = false
          return true

      cut: (event) ->
        if @preClipboard
          event.preventDefault()
          @clearClipboard(event)
          @clipboard = @preClipboard.cloneNode(true)
          $(@preClipboard).remove()
          @preClipboard = null
          return false
        else
          @preClipboard = false
          return true

      paste: (event) ->
        if @preClipboard isnt false and @clipboard?
          event.preventDefault()
          selection = window.getSelection()
          range     = selection.getRangeAt(0)
          node      = @getTopNode(selection.anchorNode)
          if $.trim(node.textContent).length is 0
            range.setStartBefore(node)
            range.setEndBefore(node)
          range.insertNode(@clipboard.cloneNode(true))
          selection.collapseToEnd()
        @$element.trigger('input')

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
