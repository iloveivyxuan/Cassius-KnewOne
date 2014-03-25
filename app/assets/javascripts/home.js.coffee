window.Making = do (exports = window.Making || {}) ->
  _$window      = $(window)
  _$document    = $(document)
  _$element     = null
  _$collection  = null
  _$spinner     = null
  _lock         = false
  _delay        = 500
  _page         = 1
  _$row         = null
  _class_col_6  = 'col-sm-6'
  _class_col_12 = 'col-sm-12'
  _element_class_col_6  = ['thing']
  _element_class_col_12 = ['feed_article']

  _compare = (left, right) ->
    _get_id = (element) ->
      element.get(0).getAttribute 'data-identifier'

    left and right and _get_id(left) is _get_id(right)

  _uniq = (list) ->
    if list.length is 0 then return []

    left = list.shift()
    right = list[0]

    if _compare(left, right)
      _uniq(list)
    else
      [left].concat(_uniq(list))

  _pack = (rows, columns) ->
    rows.push(_$row.clone().append(columns))

  _sort = (list, list_1, list_2, is_list_1 = true) ->
    if list_1.length is 0 and list_2.length is 0
      return

    if is_list_1
      if list_1.length > 0
        _pack(list, list_1.splice(0, 2))

      _sort(list, list_1, list_2, false)
    else
      if list_2.length > 0
        _pack(list, list_2.shift())

      _sort(list, list_1, list_2, true)

  exports.InitHome = ->
    $ ->
      _$element = $('html.signed_in_homepage').find('#activities')
      _$row     = $('<div />').addClass('row')
      _$spinner = _$element.next('.spinner')

      if _$element.length is 0 then return

      _$element
        .on 'load', ->
          _$spinner.show()

          setTimeout ->
            $.ajax
              url: '/?page=' + ++ _page
              dataType: 'html'
            .done (data, status, xhr) ->
              if xhr.status is 200
                _$element.append(data).trigger 'pack'
                _lock = false
              else if xhr.status is 204
                _$element.trigger 'loaded'
                $('<div />')
                  .addClass('nomore')
                  .html('没有更多了。')
                  .insertAfter(_$element)
            .fail (xhr, status, error) ->
              _$element.trigger 'loaded'
              $('<div />')
                .addClass('nomore')
                .html('出错啦，刷新下再试试？')
                .insertAfter(_$element)
          , _delay

        .on 'loaded', ->
          _$spinner.hide()

        .on 'pack', ->
          _$collection = _$element.children(':not(.row)')
          _rows        = []
          _inbox       = []
          _inbox_6     = []
          _inbox_12    = []
          _$row_last   = null

          _$collection
            .addClass('js_activity_packing')
            .each (index) ->
              _$item = $(@)

              for klass in _element_class_col_6
                if _$item.hasClass(klass)
                  _$item.addClass(_class_col_6)
                  _inbox_6.push(_$item)
                  return true

              for klass in _element_class_col_12
                if _$item.hasClass(klass)
                  _$item.addClass(_class_col_12)
                  _inbox_12.push(_$item)
                  return true

          _things = _uniq(_inbox_6)
          _articles = _uniq(_inbox_12)
          if _things.length % 2 > 0
            _things[_things.length - 1].removeClass(_class_col_6).addClass(_class_col_12)

          _sort(_rows, _things, _articles, true)

          _$element.append(_rows).trigger 'show'

        .on 'show', ->
          _$element
            .trigger 'loaded'
            .find('.js_activity_packing')
            .removeClass('js_activity_packing')
            .show()
          .end()
            .find('.row')
            .filter(':hidden')
            .fadeIn()

          exports.ImageLazyLoading()

      _$window.on 'scroll', ->
        if _$document.height() - _$window.scrollTop() -
            _$window.height() < 100 and !_lock
          _lock = true
          _$element.trigger 'load'

      _$element.trigger 'pack'

  # exports
  exports