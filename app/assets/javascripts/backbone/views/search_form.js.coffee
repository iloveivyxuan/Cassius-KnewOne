suggestionsTemplate = HandlebarsTemplates['search/suggestions']
loadingTemplate = HandlebarsTemplates['search/loading']

class Making.Views.SearchForm extends Backbone.Marionette.ItemView
  ui: {
    input: 'input[type="search"]'
    status: '.fa-search'
    clear: '.fa-times'
    menu: '.search_menu'
    suggestions: '.search_menu-suggestions'
    result: '.search_menu-result'
  }

  events: {
    'keydown @ui.input': 'onKeyDown'
    'mousedown .search_menu-suggestions li': 'onClick'
    'mousedown .search_menu-result a': 'onClick'
    'keyup @ui.input': 'onKeyUp'
    'focus @ui.input': 'onFocus'
    'blur @ui.input': 'onBlur'
    'click @ui.clear': 'onClear'
    submit: 'onSubmit'
  }

  modelEvents: {
    change: 'render'
  }

  initialize: ->
    @bindUIElements()

    @model = new Backbone.Model()
    @reset()

    @ui.input.trigger('focus') if @ui.input.is(':focus')

  inputValue: ->
    @ui.input.val().trim()

  reset: ->
    @model.set({
      loading: false
      query: @inputValue()
      suggestions: []
      selectedIndex: 0
      result: ''
    })

  render: ->
    if @model.get('suggestions').length || @model.get('result')
      @ui.menu.show()
    else
      @ui.menu.hide()

    if @model.hasChanged('loading')
      if @model.get('loading')
        @ui.status.removeClass('fa-search').addClass('fa-spinner fa-spin')

        @ui.result.html(loadingTemplate())
        @ui.result.find('.search_menu-progress').animate({width: '100%'}, 500)
      else
        @ui.status.addClass('fa-search').removeClass('fa-spinner fa-spin')

        @ui.result.find('.search_menu-progress')
          .animate({width: '100%'}, 50, =>
            @ui.result
              .hide()
              .html(@model.get('result'))
              .fadeIn()
          )
    else
      if !@model.get('loading') && @model.hasChanged('result')
        @ui.result
          .hide()
          .html(@model.get('result'))
          .fadeIn()

    @ui.input.val(@model.get('query')) if @model.hasChanged('query')

    @ui.suggestions.html(suggestionsTemplate({
      suggestions: @model.get('suggestions')
      selectedIndex: @model.get('selectedIndex')
    })) if @model.hasChanged('suggestions') || @model.hasChanged('selectedIndex')

  updateSuggestions: (query) ->
    @_cachedSuggestions ?= Object.create(null)

    return @model.set({
      suggestions: @_cachedSuggestions[query]
      selectedIndex: 0
    }) if @_cachedSuggestions[query]?

    $.ajax({
      url: '/search/suggestions'
      data: {q: query}
      dateType: 'json'
    }).done((suggestions) =>
      suggestions.unshift(query)
      @_cachedSuggestions[query] = suggestions

      @model.set({
        suggestions
        selectedIndex: 0
      }) if query == @inputValue()
    )

  updateResult: (query) ->
    @_cachedResults ?= Object.create(null)

    return @model.set({
      loading: false
      result: @_cachedResults[query]
    }) if @_cachedResults[query]?

    @model.set({loading: true})

    $.ajax({
      url: '/search'
      data: {q: query}
      dateType: 'html'
    }).done((result) =>
      @_cachedResults[query] = result
      @model.set({loading: false, result}) if query == @inputValue()
    )

  selectSuggestion: (selectedIndex) ->
    query = @model.get('suggestions')[selectedIndex]

    @model.set({query, selectedIndex})
    @updateResult(query)

  moveBy: (increment) ->
    length = @model.get('suggestions').length
    index = (@model.get('selectedIndex') + increment + length) % length
    @selectSuggestion(index)

  onKeyDown: (event) ->
    switch event.which
      when Making.keycode.UP
        @moveBy(-1)
      when Making.keycode.DOWN, Making.keycode.TAB
        if event.shiftKey
          @moveBy(-1)
        else
          @moveBy(1)
      else
        return

    event.preventDefault()

  onClick: (event) ->
    event.preventDefault()

    index = $(event.currentTarget).data('index')
    @selectSuggestion(index) if index?

  onKeyUp: _.debounce((event) ->
    query = @inputValue()
    return if query == @model.get('query')

    @model.set({query})

    return @model.set({suggestions: [], result: ''}) if query.length == 0

    @updateSuggestions(query)
    @updateResult(query)
  , 200)

  onFocus: ->
    @ui.input.select()

    query = @model.get('query')
    return if query.length == 0

    @updateSuggestions(query)
    @updateResult(query)

  onBlur: ->
    return if Making.isDebugging()

    @model.set({
      loading: false
      suggestions: []
      selectedIndex: 0
      result: ''
    })

  onClear: ->
    @ui.input.val('')
    @reset()

  onSubmit: (event) ->
    event.preventDefault() if @inputValue().length == 0
