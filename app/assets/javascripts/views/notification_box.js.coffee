Making.Views.Notification = Backbone.View.extend

  el: '#notification_box'

  events:
    'click #notification_trigger': 'fetch'

  initialize: ->
    @url         = '/notifications'
    @$relations  = @$('#notification_relations')
    @$importants = @$('#notification_importants')
    @$things     = @$('#notification_things')

    Making.Events
      .on('notifications:loaded', @loaded, @)
      .on('notifications:fail', @fail, @)

    @$relations.data('types', 'following')
    @$importants.data('types', 'stock,weibo_friend_joined,comment,new_review')
    @$things.data('types', 'love_feeling,love_review,love_topic')

  render: ->
    # TODO
    # show counts

  fetch: ->

    _.each [@$relations, @$importants, @$things], ($item, index, list) ->
      $item.find('.notifications').empty()
      $item.find('.spinner').show()

      $
        .ajax
          url: @url
          data:
            types: $.trim($item.data('types'))
          dataType: 'html'
          contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
        .done (data, status, xhr) ->
          Making.Events.trigger('notifications:loaded', data, xhr, $item)
        .fail (xhr, status, error) ->
          Making.Events.trigger('notifications:fail', xhr, $item)
    , @

  loaded: (data, xhr, $element) ->
    if xhr.status is 200
      $element.find('.notifications').html(data)
      $element.find('.spinner').hide()
      @render()

  fail: (xhr, $element) ->
    # TODO
