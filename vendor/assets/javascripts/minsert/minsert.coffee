do ($ = jQuery) ->

  if MediumEditor and typeof MediumEditor is 'function'

    # MInsert Prototype

    class MInsert

      constructor: (element, options) ->
        @$element = $(element)
        @options  = options

        @initMenu()

        @$element
          .on 'click', @toggle.bind(@)
          .on 'keyup', @toggle.bind(@)

      initMenu: ->
        menu = '' +
            '<div class="minsert">' +
              '<button class="minsert-toggle" type="button">' +
                '<i class="fa fa-plus-circle"></i>' +
              '</button>' +
              '<ul class="minsert-actions">' +
                '<li>' +
                  '<button class="minsert-action-image" type="button">' +
                    '<i class="fa fa-picture-o"></i>' +
                  '</button>' +
                '</li>' +
                '<li>' +
                  '<button class="minsert-action-video" type="button">' +
                    '<i class="fa fa-video-camera"></i>' +
                  '</button>' +
                '</li>' +
                '<li>' +
                  '<button class="minsert-action-embed" type="button">' +
                    '<i class="fa fa-code"></i>' +
                  '</button>' +
                '</li>' +
                '<li>' +
                  '<button class="minsert-action-rule" type="button">' +
                    '<i class="fa fa-minus"></i>' +
                  '</button>' +
                '</li>' +
              '</ul>' +
            '</div>';
        @$element.after(menu)

        @$minsert        = @$element.next('.minsert')
        @$minsertActions = @$minsert.children('.minsert-actions')

        @$minsert
          .on 'click', '.minsert-toggle', (event) ->
            $(event.currentTarget)
              .next('.minsert-actions')
                .toggleClass('is-shown')

      toggle: (event) ->
        selection = window.getSelection()

        if selection.anchorOffset is 0
          topNode = @getTopNode(selection.anchorNode)

          if $.trim($(topNode).text()) is ''
            @show(topNode)
          else
            @hide()
        else
          @hide()

      show: (relativeNode) ->
        @setPosition(relativeNode)
        @$minsertActions.removeClass('is-shown')
        @$minsert.addClass('is-shown')

      hide: ->
        @$minsert.removeClass('is-shown')
        @$minsertActions.removeClass('is-shown')

      getTopNode: (node) ->
        if node.parentNode.getAttribute('data-medium-element') is 'true'
          return node
        else
          return @getTopNode(node.parentNode)

      setPosition: (relativeNode) ->
        left = (@$element.offset().left - 45) + 'px'
        top  = $(relativeNode).position().top + 'px'

        @$minsert.css
          left: left
          top : top

    MInsert.DEFAULTS =
      actions:
        images: {}
        videos:
          placeholder: '在这里插入视频代码'
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
