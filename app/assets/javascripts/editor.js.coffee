window.Making = do (exports = window.Making || {}) ->
  if Modernizr.mq('(max-width: ' + exports.Breakpoints.screenMDMin + ')')
    return exports

  _$editor_compact = $('#editor_compact_experimental')
  _$editor         = $('#editor_experimental')
  _$modal          = $('#insert-video-modal')
  _$button         = $('#insert-video-button')

  _editor = new MediumEditor '.editor',
    buttons: ['header1', 'header2', 'bold', 'italic', 'quote', 'anchor', 'orderedlist', 'unorderedlist']
    buttonLabels: 'fontawesome'
    firstHeader: 'h2'
    secondHeader: 'h3'
    placeholder: '在这里记下你的想法～'

  _$editor.on 'click', '.action-videos-add', ->
    _$modal.data 'triggerMediumInsert', $(this)
  .find('.editor').mediumInsert
    imagesUploadScript: ''
    editor: _editor
    images: true
    videos: true
    videosPlugin:
      input: '#insert-video-input'
  .find('.action-videos-add').attr
    'data-toggle': 'modal'
    'data-target': '#insert-video-modal'

  _$button.on 'click', ->
    _$modal.data('triggerMediumInsert').data('deferredMediumInsert').resolve()
    _$modal.modal('hide')

  _$modal.on 'hidden.bs.modal', ->
    deferredMediumInsert = _$modal.data('triggerMediumInsert').data('deferredMediumInsert')
    $('#insert-video-input').val('')
    if deferredMediumInsert.state() is 'pending'
      deferredMediumInsert.reject()

  _$editor_compact.on 'click', ->
    _$editor.show()

  # exports
  exports
