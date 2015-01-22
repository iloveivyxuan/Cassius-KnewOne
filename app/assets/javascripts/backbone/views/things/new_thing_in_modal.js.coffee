class Making.Views.NewThingInModal extends Backbone.View
  
  events:
    'submit form': 'validate'
    'after:render': 'afterRender'
    'input textarea': 'validContentInput'
    'propertychange textarea': 'validContentInput'

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
    flag = @validatePhotos()
    if flag
      $.post @$form.attr('action'), @$form.serializeArray()
      @$form.find('button[type="submit"]').button('loading')


  addPhotoInput: (ids) ->
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
    flag = !!photoIds.length
    $container.removeClass('is-invalid') 

    if flag
      @addPhotoInput(photoIds)
    else
      $container.addClass('is-invalid')

    $('[required]').trigger('after:validate')

    flag


  validContentInput: (e) ->    
    length = @$content.val().length
    if length > @contentLength
      @$content.closest('.form-group').addClass('is-invalid')
    else
      @$content.closest('.form-group').removeClass('is-invalid')
    @$contentCounter.html("#{length} / #{@contentLength}")


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

    @$content = @$form.find('textarea')
    @$contentCounter = @$content.next()
    @contentLength = +@$content.data('maxlength')
    @$contentCounter.html("0 / #{@contentLength}")

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