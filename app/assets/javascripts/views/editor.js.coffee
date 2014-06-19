# Editor.
#
# Edit Mode: main, complemental.
#

Making.Views.Editor = Backbone.View.extend

  el: '.editor'

  events:
    'click .editor-close': 'close'
    'click .editor-submit': 'submit'

  initialize: (data) ->
    @mode     = data.mode
    # @template = HandlebarsTemplates['editor/' + data.template]
    @$form    = @$el.parents('form')
    @$help    = @$('.editor-help')
    @$submit  = @$('.editor-submit')
    @$drop    = @$('.editor-drop')
    @$close   = @$('.editor-close')
    @$output  = @$('.editor-menu output')
    @$content = @$('.editor-content')
    @$bodyField = @$('[name$="[content]"]')

    @render()

  render: ->
    @$help.popover
      html: true
      # @TODO
      content: '欢迎您在这里写下对于产品本身的使用体验，给其他对产品感兴趣的朋友们提供客观可信的参考，谢谢：）'
    if @mode is 'complemental'
      @$drop.addClass('hidden')
      @$submit.addClass('hidden')
    else
      # @TODO
      # has draft?
      if false
        # @TODO
        # loading
        $
          .ajax
            url: '/draft'
          .done (data, status, xhr) ->
            @$content.html(@template(data))
            @initPlugin()
            @$el.show()
        return
      else
        # @$content.html(@template({}))
        @initPlugin()
        @$el.show()
        return

  initPlugin: ->
    @$body = @$('.editor-content > .body')

    @editor = new MediumEditor @$body,
      buttons: ['header1', 'header2', 'bold', 'italic', 'quote', 'anchor',
                  'orderedlist', 'unorderedlist']
      buttonLabels: 'fontawesome'
      firstHeader: 'h2'
      secondHeader: 'h3'
      placeholder: '正文'
      targetBlank: true

    @$body.mediumInsert
      editor: @editor
      addons:
        images: {}
        embeds: {}

  saveDraft: ->
    console.log 'TODO: save draft.'

  close: ->
    # @TODO
    @saveDraft()
    @$el.hide()
    $docbody.removeClass('editor-open')

  submit: (event) ->
    @$bodyField.val(@editor.serialize()['element-0'].value)
    @$form.submit()
