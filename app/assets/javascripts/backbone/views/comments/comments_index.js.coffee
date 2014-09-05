class Making.Views.CommentsIndex extends Backbone.View

  template: HandlebarsTemplates['comments/index']

  events:
    'submit #create_comment': 'create'
    'click .comments_more': 'fetch'

  initialize: ->
    @page     = 1
    @anchor   = @getAnchor()
    @anchorId = @getAnchorId()
    @render()
    @collection.on
      add: @prepend
      reset: (comments) =>
        comments.each @append
        if @anchor.length > 0
          @jumpToAnchor()
    @fetch(@anchorId)

  fetch: (fromId) =>
    if fromId?
      data = {from_id: fromId}
    else
      data = {page: @page++}
    @collection.fetch
      reset: true
      data: data
      beforeSend: =>
        @$('ul').append(HandlebarsTemplates['shared/loading'])

  render: =>
    @$el.html @template
      title: @$el.data('title')
      signin: @$el.data('signin')
      auth: @$el.data('auth')
      more: @$el.data('count') > @$el.data('per')

    Making.AtUser('.comments textarea')
    @$submit = @$('[type="submit"]')

    @disableForm() unless @$el.data("signin") and @$el.data("auth")
    this

  disableForm: =>
    $('#create_comment')
      .find('textarea,button').prop('disabled', true).addClass('disabled')

  create: (e) ->
    e.preventDefault()
    @$submit.disable()
    @collection.create
      content: @$('textarea').val()
    ,
      wait: true
      success: =>
        @$('textarea').val("")
        $comments_count = @$el.parents('.feed_article, .feed-feeling').find('.comments_count, .comments-count')
        initial = parseInt($comments_count.text())
        result = if isNaN(initial) then 1 else initial + 1
        $comments_count.text(result)
        @$submit.enable()

  append: (comment) =>
    view = new Making.Views.Comment(model: comment)
    view.render().$el.hide().appendTo(@$('ul')).fadeIn()
    if @$('ul li').length >= @$el.data('count')
      @$('.comments_more').hide()

  prepend: (comment) =>
    view = new Making.Views.Comment(model: comment)
    view.render().$el.hide().prependTo(@$('ul')).fadeIn()

  getAnchor: =>
    hash = location.hash
    if hash.length is 0 then return ''
    endpoint = hash.indexOf('?')
    if endpoint < 0
      return hash
    else
      return hash.slice(0, endpoint)

  getAnchorId: =>
    return @anchor.replace('#comment-', '')

  jumpToAnchor: =>
    $anchor = $("#{@anchor}")
    $window.scrollTop($anchor.offset().top - 55)
    $anchor.parent().addClass('is-targeted')
