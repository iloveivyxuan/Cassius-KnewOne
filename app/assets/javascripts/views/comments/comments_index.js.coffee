class Making.Views.CommentsIndex extends Backbone.View

  template: HandlebarsTemplates['comments/index']

  events:
    'submit #create_comment': 'create'
    'click .comments_more': 'fetch'

  initialize: ->
    @page = 1
    @render()
    @collection.on
      add: @prepend
      reset: (comments) =>
        comments.each @append
    @fetch()

  fetch: =>
    @collection.fetch
      reset: true
      data: {page: @page++}
      beforeSend: =>
        @$('ul').append(HandlebarsTemplates['shared/loading'])
      success: =>
        console.log @collection

  render: =>
    @$el.html @template(
      title: @$el.data('title'),
      signin: @$el.data('signin'),
      more: @$el.data('count') > @$el.data('per')
    )
    @disableForm() unless @$el.data("signin")
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
    view.render().$el.hide().appendTo(@$('ul')).fadeIn()
    if @$('ul li').length >= @$el.data('count')
      @$('.comments_more').hide()

  prepend: (comment) =>
    view = new Making.Views.Comment(model: comment)
    view.render().$el.hide().prependTo(@$('ul')).fadeIn()
