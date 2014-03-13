window.Making = do (exports = window.Making || {}) ->
  if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
    _$element = $('#notification_box')
    _$count   = $('#notification_count')
    _$trigger = $('#notification_trigger')
    _$box     = _$element.find('.dropdown_box')
    _$content = _$element.find('.notifications')
    _$spin    = _$element.find('.spinner')
    _url      = _$trigger.data('url')

    _$trigger.attr('data-toggle', 'dropdown')

    _$element
      .on 'click', '#notification_trigger', ->
        if _$box.is(':hidden')
          _$content.empty()
          _$element.trigger 'loading'
          $.ajax
            url: _url
            dataType: 'html'
            contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
          .done (data, status, xhr) ->
            if xhr.status is 200
              _$element.trigger 'loaded'
              _$content.html(data)
              _$count.text('')
      .on 'loading', ->
        _$spin.show()
      .on 'loaded', ->
        _$spin.hide()

  # exports
  exports