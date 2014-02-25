window.Making = do (exports = window.Making || {}) ->
  if Modernizr.mq('(max-width: ' + exports.Breakpoints.screenMDMin + ')')
    return exports

  _$editor_compact = $('#editor_compact_experimental')
  _$editor         = $('#editor_experimental')
  _$modal          = $('#insert-video-modal')

  _editor = new MediumEditor '.editor',
    buttons: ['header1', 'header2', 'bold', 'italic', 'underline', 'quote', 'anchor', 'orderedlist', 'unorderedlist']
    buttonLabels: 'fontawesome'
    firstHeader: 'h2'
    secondHeader: 'h3'
    placeholder: '快来写点什么吧～'

  $('.editor').mediumInsert
    imagesUploadScript: ''
    editor: _editor
    images: true
    videos: true
    videosPlugin:
      input: '#insert-video-input'
  .find('.action-videos-add').attr
    'data-toggle': 'modal'
    'data-target': '#insert-video-modal'
  .on 'click', ->
    _$modal.data 'triggerMediumInsert', $(this)

  $('#insert-video-button').on 'click', ->
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
