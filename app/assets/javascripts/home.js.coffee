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
  _class_single = 'single'
  _class_col_6  = 'col-sm-6'
  _class_col_12 = 'col-sm-12'
  _element_class_col_6  = ['thing']
  _element_class_col_12 = ['article_compact']

  _sort = (list, list_1, list_2, is_list_1 = true) ->
    if list_1.length == 0 and list_2.length == 0
      return

    if is_list_1
      if list_1.length % 2 > 0
        list.push(list_1.shift())
      else if list_1.length > 0
        list.push(list_1.shift(), list_1.shift())

      _sort(list, list_1, list_2, false)
    else
      if list_2.length > 0
        list.push(list_2.shift())

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
          , _delay

        .on 'loaded', ->
          _$spinner.hide()

        .on 'pack', ->
          _$collection = _$element.children(':not(.row)')
          _rows        = []
          _inbox       = []
          _inbox_6     = []
          _inbox_12    = []
          _$row_first  = null

          _$collection
            .addClass('js-packing')
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

          _sort(_inbox, _inbox_6, _inbox_12, true)

          while _inbox.length > 0
            _rows.push(
              _$row.clone().append ->
                _items = []

                if $(_inbox[0]).hasClass(_class_col_6) and
                  $(_inbox[1]).hasClass(_class_col_6)
                    _items.push(_inbox.shift(), _inbox.shift())
                  else
                    _items.push(_inbox.shift())

                return _items
            )

          _$row_first = $(_rows[0])
          _$row_first_children = _$row_first.children()

          if _$row_first_children.length is 1 and _$row_first_children.hasClass(_class_col_6)
            _$row_first.addClass(_class_single)
            _$row_first_children.removeClass(_class_col_6).addClass(_class_col_12)

          _$element.append(_rows).trigger 'show'

        .on 'show', ->
          _$element
            .trigger 'loaded'
            .find('.js-packing')
            .removeClass('js-packing')
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