window.Making = do (exports = window.Making || {}) ->
  if Modernizr.mq('(max-width: ' + exports.Breakpoints.screenMDMin + ')')
    return exports

  _$editor_compact = $('#editor_compact_experimental')
  _$editor         = $('#editor_experimental')

  _editor = new MediumEditor '.editor',
    buttons: ['header1', 'header2', 'bold', 'italic', 'quote', 'anchor', 'orderedlist', 'unorderedlist']
    buttonLabels: 'fontawesome'
    firstHeader: 'h2'
    secondHeader: 'h3'
    placeholder: '在这里记下你的想法～'
    targetBlank: true

  _$editor.on 'click', '.action-videos-add', ->
    _$modal.data 'triggerMediumInsert', $(this)
  .find('.editor').mediumInsert
    editor: _editor
    addons:
      images:
        imagesUploadScript: ''
      embeds: {}

  _$editor_compact.on 'click', ->
    _$editor.show()

  # exports
  exports
