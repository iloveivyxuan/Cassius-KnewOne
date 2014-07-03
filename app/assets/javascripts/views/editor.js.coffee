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
      @$submit    = @$('.editor-submit')
      @$drop      = @$('.editor-drop')
      @$close     = @$('.editor-close')
      @$output    = @$('.editor-menu output')
      @$content   = @$('.editor-content')
      @$body      = @$content.children('.body')
      @$fields    = @$content.find('[name]')
      @$bodyField = @$('[name$="[content]"]')
      @draft      = new exports.Models.Draft
                      type: options.type
                      id: exports.user + '+draft+' +
                            encodeURIComponent(location.pathname) +
                            '+#' + (@el.id ? '')
                      link: location.href

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
              url: @draft.url()
              type: 'get'
            .done (data, status, xhr) ->
              that.getContent(data)
            .fail (xhr, status, error) ->
              if (typeof localStorage[that.draft.get('id')]) isnt 'undefined'
                that.getContent(JSON.parse(localStorage[that.draft.get('id')]))
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
      key       = exports.user + '+hide-editor-help'
      isHide    = localStorage[key]
      $checkbox = $('#show-editor-help')

      if isHide is 'true'
        $checkbox.attr('checked', true)
      else
        $checkbox.removeAttr('checked')

      if $checkbox.prop('checked') isnt true
        $('#editor-help').modal('show')

      $checkbox.on 'change', ->
        localStorage[key] = $(@).prop('checked')

    initWidget: ->
      !@$rating && (@$rating = @$('.range-rating')).length && @$rating.rating()

    getBody: ->
      @$body.html(@$bodyField.val())

    setBody: ->
      @$bodyField.val(@editor.serialize()[@$body.attr('id')].value)

    setContent: ->
      @setBody()

      _.each @$fields, (element, index, list) ->
        $field = $(element)
        @draft.set($field.attr('name'), $field.prop('value'))
      , @

    getContent: (content) ->
      _.each @$fields, (element, index, list) ->
        $field = $(element)
        key    = $field.prop('name')
        $field.prop('value', content[key])
      , @

      @getBody()

    save: (persisten, callback) ->
      @setContent()
      draft = @draft.toJSON()

      @model.updateStatus('save')

      if persisten is true
        that  = @

        @draft.save null,
          success: (model, response, options) ->
            localStorage.removeItem(that.draft.get('id'))
            that.model.updateStatus('edit')
            that.model.set('persisten', true)
            if callback then callback()
      else
        localStorage[@draft.get('id')] = JSON.stringify(draft)
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

        @draft.destroy
          success: ->
            localStorage.removeItem(that.draft.get('id'))
            callback()

    submit: (event) ->
      that = @

      $window
        .off 'unload'
        .off 'beforeunload'

      # @FIXME
      # 提交表单，同时删除草稿（本地＋服务器），
      # 愿主保佑不会遇到删除草稿成功但提交表单失败的情况。
      localStorage.removeItem(that.draft.get('id'))
      @draft.destroy()

      @model.updateStatus('submit')

      @setBody()

    # @TODO
    send: ->
      @save(true)

    beforeunload: ->
      if !@model.get('persisten')
        return '文档还未保存，确定要离开吗？'

    unload: ->
      localStorage.removeItem(@draft.get('id'))
