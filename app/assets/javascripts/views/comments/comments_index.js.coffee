class Making.Views.CommentsIndex extends Backbone.View

  template: HandlebarsTemplates['comments/index']

  events:
    'submit #create_comment': 'create'
    'click .all': 'all'

  initialize: ->
    @start = 50
    @collection.on
      reset: @renderList
      add: @fadeAppend
    @render()
    @collection.fetch
      beforeSend: =>
        @$('ul').html(HandlebarsTemplates['shared/loading'])

  render: =>
    @$el.html @template(title: @$el.data('title'), count: @$el.data('count'))
    if @$el.data("signin")
      $('#create_comment p.login_tip').hide()
    else
      @disableForm()

    @$('.all').hide()
    this

  renderList: =>
    if @collection.length > @start
      @$('.all').show()
    _.each @collection.first(@start), @append
    this

  disableForm: =>
    $('#create_comment')
      .find('textarea,button').prop('disabled', true).addClass('disabled')

  create: (e) ->
    e.preventDefault()
    @collection.create
      content: @$('textarea').val()
    ,
      wait: true
      success: =>
        @$('textarea').val("")

  append: (comment) =>
    view = new Making.Views.Comment(model: comment)
    view.render().$el.appendTo @$('ul')

  fadeAppend: (comment) =>
    view = new Making.Views.Comment(model: comment)
    view.render().$el.hide().appendTo(@$('ul')).fadeIn()

  all: (e) =>
    e.preventDefault()
    $(e.target).remove()
    _.each @collection.rest(@start), @append    
