window.Making = do (exports = window.Making || {}) ->
  _$window      = $(window)
  _$document    = $(document)
  _$element     = null
  _$collection  = null
  _$spinner     = null
  _lock         = false
  _delay        = 300
  _page         = 1
  _rows         = []
  _$row         = null
  _class_col_6  = 'col-sm-6'
  _class_col_12 = 'col-sm-12'
  _element_class_col_6  = ['thing']
  _element_class_col_12 = ['article_compact']

  exports.InitHome = ->
    $ ->
      _$element = $('html.signed_in_homepage').find('#activities')
      _$row     = $('<div />').addClass('row')
      _$spinner = _$element.next('.spinner')

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
          _length      = _$collection.length
          _inbox_6     = []
          _inbox_12    = []

          _$collection.addClass('js-packing')

          _$element_col_6 = _$collection.filter ->
            _result = false

            for klass in _element_class_col_6
              _result = $(@).hasClass(klass)
              if _result then break

            return _result

          if _$element_col_6.length % 2 isnt 0
            _$element_col_6.first().addClass('js-first')

          _$collection.each (index) ->
            _$item = $(@)

            if _$item.hasClass('js-first')
              _rows.push(
                _$row.clone()
                  .append(
                    _$item
                      .addClass(_class_col_12)
                      .removeClass('js-first')
                  )
                )

              return true

            for klass in _element_class_col_6
              if _$item.hasClass(klass)
                _$item.addClass(_class_col_6)
                _inbox_6.push(_$item)

                if _inbox_6.length is 2
                  _rows.push(_$row.clone().append(_inbox_6))
                  _inbox_6 = []

                return true

            for klass in _element_class_col_12
              if _$item.hasClass(klass)
                _$item.addClass(_class_col_12)
                _inbox_12.push(_$item)

                if _inbox_12.length is 1
                  _rows.push(_$row.clone().append(_inbox_12))

                return true

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
            .show()

          exports.ImageLazyLoading()

      _$window.on 'scroll', ->
        if _$document.height() - _$window.scrollTop() -
            _$window.height() < 100 and !_lock
          _lock = true
          _$element.trigger 'load'

      _$element.trigger 'pack'

  # exports
  exports