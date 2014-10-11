class Making.Views.CommentsIndex extends Backbone.View
  events:
    'submit #create_comment': 'create'
    'click .comments_more': 'fetch'
    'click .reply': 'reply'

  initialize: ({url}) ->
    @url       = url
    @anchor    = @getAnchor()
    @commentId = @getCommentId()
    @render()

    if @commentId || @getCommentsCount() == 0
      @fetch(@commentId)

  fetch: (fromId) =>
    if typeof fromId is 'string'
      data = {from_id: fromId}
    else
      data = {page: @getNextPageNumber()}

    $.ajax({
      url: @url
      data
      beforeSend: => @$('ul').append(HandlebarsTemplates['shared/loading'])
    }).success((data) =>
      @$('ul').append(data)

      $('.spinning').remove()

      if @anchor.length > 0
        @jumpToAnchor()
        @anchor = ''

      @$('.comments_more').remove() if @getCommentsCount() == @$el.data('count')
    )

  render: =>
    Making.AtUser('.comments textarea')
    @$submit = @$('[type="submit"]')
    this

  create: (e) ->
    e.preventDefault()
    @$submit.disable()

    $.ajax({
      url: @url
      type: 'POST'
      data: {comment: {content: @$('textarea').val()}}
    }).success((html) =>
      @prepend(html)

      @$('textarea').val("")
      $comments_count = @$el.parents('.feed_article, .feed-feeling').find('.comments_count, .comments-count')

      if $comments_count.length == 0
        $comments_count = $('<span class="comments_count"></span>')
        $comments_count.appendTo(@$el.parents('.feed_article').find('.comments_toggle'))

      initial = parseInt($comments_count.text())
      result = if isNaN(initial) then 1 else initial + 1
      $comments_count.text(result)
      @$submit.enable()
    )

  prepend: (html) =>
    $(html).hide().prependTo(@$('ul')).fadeIn()

  getCommentsCount: ->
    @$('ul > li').length

  getNextPageNumber: ->
    Math.floor(@getCommentsCount() / @$el.data('per')) + 1

  getAnchor: =>
    hash = location.hash
    return '' if hash.indexOf('#comment-') == -1
    endpoint = hash.indexOf('?')
    if endpoint < 0
      return hash
    else
      return hash.slice(0, endpoint)

  getCommentId: =>
    return @anchor.replace('#comment-', '')

  jumpToAnchor: =>
    $anchor = $("#{@anchor}")
    $window.scrollTop($anchor.offset().top)
    $anchor.parent().addClass('is-targeted')

  reply: (event) ->
    event.preventDefault()

    authorName = $(event.currentTarget).siblings('.author_name').text()
    $textarea = $('form#create_comment textarea')

    $textarea
      .focus()
      .val($textarea.val() + " @#{authorName} ")
