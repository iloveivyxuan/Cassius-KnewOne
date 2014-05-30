Making.Views.Notification = Backbone.View.extend

  el: '#notification_box'

  events:
    'click #notification_trigger': 'fetch'

  initialize: ->
    @url = '/notifications'
    @spinner_template = $('#notification_box .dropdown_box').html()
    @$content = $('#notification_box .dropdown_box')

    Making.Events
    .on('notifications:loaded', @loaded, @)

  fetch: ->
    @$content.html(@spinner_template)

    $
    .ajax
        url: @url
        dataType: 'html'
        contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
    .done (data, status, xhr) ->
      Making.Events.trigger('notifications:loaded', data, xhr)

  loaded: (data, xhr) ->
    if xhr.status is 200
      @$content.html(data)
