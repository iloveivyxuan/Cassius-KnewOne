Making.Views.Notification = Backbone.View.extend

  el: '#notification_box'

  events:
    'click #notification_trigger': 'markRead'

  initialize: ->
    @url = '/notifications'
    @spinner_template = $('#notification_box .dropdown_box').html()
    @$content = $('#notification_box .dropdown_box')
    @$count = @$('#notification_count')

    Making.Events
    .on('notifications:loaded', @loaded, @)

    @fetch()

  fetch: ->
    @$content.html(@spinner_template)

    $
    .ajax
        url: @url
        dataType: 'html'
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
    .success (data) =>
      @$content.html(data)

  markRead: ->
    return unless @$count.text()

    $
    .ajax
      type: 'POST'
      url: "#{@url}/mark"
      dataType: 'json'
    .success =>
      @$count.text('')
