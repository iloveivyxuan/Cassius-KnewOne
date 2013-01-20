class Making.Views.ReviewsIndex extends Backbone.View

  template: JST['reviews/index']

  events:
    'click #new_review button': 'new'
    'submit #create_review': 'create'

  initialize: ->
    @collection.on
      reset: @render
      add: @prepend

  render: =>
    $(@el).html(@template())
    @collection.each @append
    this

  new: (e) ->
    @$('#new_review').hide()
    $form = @$('#review_form_template')
      .clone().attr('id', 'create_review')
      .prependTo(@$el).show()
    Making.Editor $form

  create: (e) ->
    e.preventDefault()
    @collection.create
      title: @$('input').val()
      content: @$('textarea').val()
    ,
      wait: true
      success: ->
        @$('#create_review').remove()
        @$('#new_review').show()
      error: ->
        console.log "error!"

  append: (review) =>
    view = new Making.Views.Review(model: review)
    @$('> ul').append(view.render().el)

  prepend: (review) =>
    view = new Making.Views.Review(model: review)
    @$('> ul').prepend(view.render().el)
