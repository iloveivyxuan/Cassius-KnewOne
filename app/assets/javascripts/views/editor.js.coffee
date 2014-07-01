# Editor.
#
# Edit Mode:
#   standalone: Init from new page.
#   complemental: Init from current page.
#

do (exports = Making) ->

  exports.Views.Editor = Backbone.View.extend

    events:
      'change [name]'                : 'save'
      'input .editor-content > .body': 'save'
      'click .editor-close'          : 'close'
      'click .editor-drop'           : 'drop'
      'click .editor-save'           : 'send'
      'click .editor-submit'         : 'submit'

    initialize: (options) ->
      @mode       = options.mode
      @type       = options.type
      @draftId    = exports.user +
                    '+draft+' +
                    encodeURIComponent(location.pathname) +
                    '+#' + (@el.id ? '')
      @url        = location.origin + '/drafts/' + @draftId
      @$help      = @$('.editor-help')
      @$submit    = @$('.editor-submit')
      @$drop      = @$('.editor-drop')
      @$close     = @$('.editor-close')
      @$output    = @$('.editor-menu output')
      @$content   = @$('.editor-content')
      @$body      = @$content.children('.body')
      @$fields    = @$content.find('[name]')
      @$bodyField = @$('[name$="[content]"]')

      @listenTo @model, 'change:status', @showStatus

      @render()

    render: ->
      switch @mode
        when 'standalone'
          that = @

          @model.updateStatus('load')
          @$close.addClass('hidden')

          $
            .ajax
              url: that.url
              type: 'get'
            .done (data, status, xhr) ->
              that.setContent(JSON.parse(data.content))
            .fail (xhr, status, error) ->
              if (typeof localStorage[that.draftId]) isnt 'undefined'
                that.setContent(JSON.parse(JSON.parse(localStorage[that.draftId]).content))
            .always ->
              that.model.updateStatus('edit')
              that.show()
              that.initWidget()
              that.initHelp()
        when 'complemental'
          # @TODO
          @$drop.addClass('hidden')
          @$submit.addClass('hidden')
      @

    # @TODO
    reset: ->
      console.log 'TODO: reset.'

    show: ->
      that = @
      @getBody()
      @activatePlugin()
      @$el.show()

      $window
        .on 'beforeunload', (_.bind @beforeunload, @)
        .on 'unload', (_.bind @unload, @)

    hide: ->
      @$el.hide()
      $docbody.removeClass('editor-open')
      $window
        .off 'unload'
        .off 'beforeunload'

    showStatus: ->
      @$output.text(@model.get('status'))

    activatePlugin: ->
      @editor = new MediumEditor @$body,
        buttons: ['anchor', 'bold', 'italic', 'header1', 'header2',
                    'orderedlist', 'unorderedlist', 'quote']
        buttonLabels: 'fontawesome'
        firstHeader: 'h2'
        secondHeader: 'h3'
        placeholder: '正文'
        anchorInputPlaceholder: '在这里插入链接'
        targetBlank: true

      @$body.mediumInsert
        editor: @editor
        addons:
          images:
            useDragAndDrop: false
            domain: $('#file').data('domain')
            templateFile: $('#file')
          embeds: {}

    deactivatePlugin: ->
      @editor.deactivate()
      @$body.mediumInsert('disable')

    initHelp: ->
      self = @
      @$help
        .popover
          html: true

    initWidget: ->
      !@$rating && (@$rating = @$('.range-rating')).length && @$rating.rating()

    getBody: ->
      @$body.html(@$bodyField.val())

    setBody: ->
      @$bodyField.val(@editor.serialize()[@$body.attr('id')].value)

    getContent: ->
      content =
        type: @type

      @setBody()

      _.each @$fields, (element, index, list) ->
        $field = $(element)
        content[$field.attr('name')] = $field.prop('value')
      , @

      @model.get('draft').content = JSON.stringify(content)

      return @model.get('draft')

    setContent: (content) ->
      _.each @$fields, (element, index, list) ->
        $field = $(element)
        key    = $field.prop('name')
        $field.prop('value', content[key])
      , @

      @getBody()

    save: (persisten, callback) ->
      @model.updateStatus('save')

      if persisten is true
        that  = @
        draft = @getContent()

        $
          .ajax
            url: that.url
            type: 'put'
            data:
              draft: draft
          .done (data, status, xhr) ->
            localStorage.removeItem(that.draftId)
            that.model.updateStatus('edit')
            that.model.set('persisten', true)
            if callback then callback()
      else
        localStorage[@draftId] = JSON.stringify(@getContent())
        @model.set('persisten', false)
        @model.updateStatus('edit')

    close: ->
      callback = null

      switch @mode
        when 'complemental'
          callback = @hide

      @save true, callback

    drop: ->
      if confirm '确定舍弃文档吗？'
        that     = @
        callback = null

        switch @mode
          when 'standalone'
            callback = ->
              window.close()
          when 'complemental'
            callback = ->
              @hide()
              @reset()
              @deactivatePlugin()
              @$el.data('editor', null)

        @model.updateStatus('drop')
        $window
          .off 'unload'
          .off 'beforeunload'

        $
          .ajax
            url: that.url
            type: 'delete'
          .always ->
            localStorage.removeItem(that.draftId)
            callback()

    submit: (event) ->
      that = @

      $window
        .off 'unload'
        .off 'beforeunload'

      # @FIXME
      # 提交表单，同时删除草稿（本地＋服务器），
      # 愿主保佑不会遇到删除草稿成功但提交表单失败的情况。
      localStorage.removeItem(that.draftId)
      $.ajax
        url: that.url
        type: 'delete'

      @model.updateStatus('submit')

      @setBody()

    # @TODO
    send: ->
      @save(true)

    beforeunload: ->
      if !@model.get('persisten')
        return '文档还未保存，确定要离开吗？'

    unload: ->
      localStorage.removeItem(@draftId)
