window.Making = do (exports = window.Making || {}) ->

  if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
    _$window   = $(window)
    _$document = $(document)
    _$html     = $('html')
    _$element  = $('#notification_box')
    _$count    = $('#notification_count')
    _$trigger  = $('#notification_trigger')
    _$box      = _$element.find('.dropdown_box')
    _$body     = _$box.find('.dropdown_box_body')
    _$content  = _$body.find('.notifications')
    _$spin     = _$body.find('.spinner')
    _url       = _$trigger.data('url')
    _height    = _$window.height() * 0.4
    _$navbar   = $('.navbar')
    _scrollbar_width = exports.GetScrollbarWidth()

    _$trigger.attr('data-toggle', 'dropdown')
    _$body.height(_height)

    _$window.on 'resize', ->
      _height = _$window.height() * 0.4
      _$body.height(_height)

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
      .on 'mouseenter mouseleave', '.dropdown_box', (event) ->
        if _scrollbar_width > 0 and _$document.height() > _$window.height()
          _$html.css('margin-right',
            (if event.type is 'mouseenter' then _scrollbar_width else 0) + 'px')
          _$navbar.css('padding-right',
            (if event.type is 'mouseenter' then _scrollbar_width else 0) + 'px')

  # exports
  exports