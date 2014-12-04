Making.Views.Notification = Backbone.View.extend

  el: '#notification_box'

  events:
    'click #notification_trigger': 'openNotification'
    'click .nav > li': 'openTab'

  initialize: ->
    @url = '/notifications'
    @spinner_template = $('#notification_box .dropdown_box').html()
    @$content = $('#notification_box .dropdown_box')
    @$count = @$('#notification_count')
    @$trigger = @$('#notification_trigger')

    Making.Events
    .on('notifications:loaded', @loaded, @)

    if @$count.text()
      @fetch()
    else
      @$trigger.one('click', => @fetch())


  fetch: ->
    @$content.html(@spinner_template)

    $
    .ajax
        url: @url
        dataType: 'html'
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
    .success (data) =>
      @$content.html(data)

  markRead: (type, count) ->
    $
    .ajax
      type: 'POST'
      url: "#{@url}/mark"
      data: { type: type }
      dataType: 'json'
    .success =>
      unread_count = @$count.text() - count
      if unread_count > 0
        @$count.text(unread_count)
      else
        @$count.text('')
        @$trigger.attr('title', '没有未读消息')

  openNotification: (event) ->
    @markRead $("#notification_box .tab-pane.active").attr("id"), $('li.active').attr('data-unread-count')

  openTab: (event) ->
    type = $(event.target.parentElement).attr("href")
    element = event.target.parentElement
    $(element).find('span.unread').remove()
    unread_count = $(event.target).parents("li").attr("data-unread-count")
    @markRead(type, unread_count)
