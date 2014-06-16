window.Making = do (exports = window.Making || {}) ->
  $ ->
    if Modernizr.mq('(max-width: ' + exports.Breakpoints.screenMDMin + ')')
      return exports

    _$editor_compact = $('#editor_compact_experimental')
    _$container      = $('.editor-container')
    _$editor         = $('.editor')

    _editor = new MediumEditor '.editor > .content',
      buttons: ['header1', 'header2', 'bold', 'italic', 'quote', 'anchor', 'orderedlist', 'unorderedlist']
      buttonLabels: 'fontawesome'
      firstHeader: 'h2'
      secondHeader: 'h3'
      placeholder: '在这里记下你的想法～'
      targetBlank: true

    console.log $('.editor > .content')
    $('.editor > .content').mediumInsert
      editor: _editor
      addons:
        images:
          imagesUploadScript: ''
        embeds: {}

    _$editor_compact.on 'click', ->
      _$container.show()
      $docbody.addClass('editor-open')

  # exports
  exports
