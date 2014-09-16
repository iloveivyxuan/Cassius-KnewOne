Making.Views.Notification = Backbone.View.extend

  el: '#notification_box'

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
    .done (data, status, xhr) ->
      Making.Events.trigger('notifications:loaded', data, xhr)

  loaded: (data, xhr) ->
    if xhr.status is 200
      @$content.html(data)
      @$count.text('')
