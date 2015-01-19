class Making.Views.NewThingInModal extends Backbone.View
  
  events:
    'submit form': 'validate'
    'after:render': 'afterRender'

  attributes: ->
    id: 'new-thing-from-local'
    class: 'modal fade thing new-thing local'
    'data-keyboard': 'false'


  initialize: (options = {}) ->
    @options = options
    @render()
    this

  validate: (e) ->
    e.preventDefault()
    photoIds = @validatePhotos()
    if photoIds.length
      @renderPhotos(photoIds)
      $.post @$form.attr('action'), @$form.serializeArray()
      @$form.find('button[type="submit"]').button('loading')


  renderPhotos: (ids) ->
    $group = $('#photo_hidden_group').empty()
    $.each ids, (index, id) =>
      $('<input>').attr
        name: "thing[photo_ids][]"
        value: id
        type: "hidden"
      .appendTo $group


  validatePhotos: ->
    $container = $('#photos-for-new-thing')
    photoIds = $('#photos-for-new-thing .uploaded').map (index, elem) ->
      $(elem).data('photo-id')

    $container.removeClass('is-invalid')
    $container.addClass('is-invalid') unless photoIds.length
    $('[required]').trigger('after:validate')

    photoIds


  renderProgress: ->
    @$el.html """
    <div class="progress progress-striped active">
      <div class="progress-bar" style="width: 100%;"></div>
    </div>
    """


  renderPhotoView: ->
    @photoView = new Making.Views.PhotosUpload(
      $.extend {form: '#new_thing', container: '#photos-for-new-thing', helper: false}, @options['photo']
    )
    @photoView.render()
    @listenTo @photoView, 'done', =>
      @validatePhotos()


  afterRender: ->
    @$form = @$el.find('form')
    Making.validator('#new_thing')
    Making.AtUser('#new-thing-from-local textarea')


  render: ->
    @renderProgress()
    $(document.body).append(@el)

    $.get('/things/new').done (resp) =>
      @$el.html(resp) 
      @renderPhotoView()
      @$el.trigger 'after:render'
    this