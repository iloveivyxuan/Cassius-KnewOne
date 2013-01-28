class Making.Views.CommentsIndex extends Backbone.View

  template: HandlebarsTemplates['comments/index']

  events:
    'submit #create_comment': 'create'
    'click .all': 'all'

  initialize: ->
    @start = 20
    @collection.on
      reset: @render
      add: @prepend
    @collection.fetch
      beforeSend: =>
        @$el.html(HandlebarsTemplates['shared/loading'])

  render: =>
    @$el.html @template(title: @$el.data('title'))
    unless @$el.data("signin")
      @$('#create_comment').hide()
    if @collection.length <= @start
      @$('.all').hide()
    _.each @collection.first(@start), @append
    this

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

  prepend: (comment) =>
    view = new Making.Views.Comment(model: comment)
    view.render().$el.hide().prependTo(@$('ul')).fadeIn()

  all: (e) =>
    e.preventDefault()
    $(e.target).remove()
    _.each @collection.rest(@start), @append    

  
    
