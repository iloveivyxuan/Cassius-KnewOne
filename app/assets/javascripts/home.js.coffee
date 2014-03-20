window.Making = do (exports = window.Making || {}) ->
  _$element     = null
  _$collection  = null
  _$spinner     = null
  _page         = 1
  _class_row    = 'row'
  _class_col_6  = 'col-sm-6'
  _class_col_12 = 'col-sm-12'
  _element_class_col_6  = ['thing']
  _element_class_col_12 = ['article_compact']

  exports.InitHome = ->
    $ ->
      if Modernizr.mq('(min-width: ' + Making.Breakpoints.screenSMMin + ')')
        _$element = $('html.signed_in_homepage').find('#activities')
        _$spinner = _$element.next('.spinner')

        _$element
          .on 'loading', ->
            _$spinner.show()

            $.ajax
              url: '/?page=' + ++ _page
              dataType: 'html'
              contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
            .done (data, status, xhr) ->
              if xhr.status is 200
                _$element.append(data).trigger 'sort'

          .on 'sort', ->
            _$collection = _$element.children(':not(.row)')
            _length      = _$collection.length
            _inbox_6     = []

            _$collection.each (index) ->
              _$item = $(@)

              for klass in _element_class_col_12
                if _$item.hasClass(klass)
                  _$element.append($('<div />').addClass('row').append(_$item.addClass(_class_col_12)))
                  false

              for klass in _element_class_col_6
                if _$item.hasClass(klass)
                  _inbox_6.push(_$item)

                  if _inbox_6.length is 2
                    $.each _inbox_6, -> @.addClass(_class_col_6)
                    _$element.append($('<div />').addClass('row').append(_inbox_6))
                    _inbox_6 = []
                  else if index is _length - 1 and _inbox_6.length is 1
                    $.each _inbox_6, -> @.addClass(_class_col_12)
                    _$element.append($('<div />').addClass('row single').append(_inbox_6))
                    _inbox_6 = []

                  true

            _$element.trigger 'show'

          .on 'show', ->
            _$spinner.hide()
            _$collection.show()

          .trigger 'sort'

  # exports
  exports