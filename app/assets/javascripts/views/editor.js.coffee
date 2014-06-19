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
            if !@editor
              @initPlugin()
            @$el.show()
      else
        # @$content.html(@template({}))
        if !@editor
          @initPlugin()
        @$el.show()
    @initWidget()
    @initHelp()
    return @


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

  initHelp: ->
    self = @
    @$help
      .popover
        html: true
      .popover('show')

    setTimeout ->
      self.$help.popover('hide')
    , 3000

  initWidget: ->
    !@$rating && (@$rating = @$('.range-rating')).length && @$rating.rating()

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
