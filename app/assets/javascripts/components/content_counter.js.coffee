class ContentCounter
  constructor: (elem, @options) ->
    @$elem = $(elem)
    @maxlength = @options['maxlength']
    @bindEvents()


  bindEvents: ->
    _that = this
    @inputEventCallBack = ->
      _that.whenInput.apply(_that, arguments)

    @$elem.bind 'input propertychange', @inputEventCallBack

    if @options['stopflow']
      @$elem.on 'overflow:counter', (e, length, maxlength) =>
        @$elem.val @$elem.val().substr 0, maxlength
        @updateCounter maxlength


  whenInput: (e) ->
    length = @$elem.val().length

    if @isOverflow = length > @maxlength
      @$elem.trigger 'overflow:counter', [length, @maxlength, this]
      unless @options['stopflow']
        @updateCounter(length)
    else
      @updateCounter(length)


  updateCounter: (length) ->
    if @options['autoCountDown'] == true
      @options['countDownFn'].call(this, @$counter, length, @maxlength)
    @$elem.trigger 'updated:counter', [length, @maxlength, this]


  renderCountNumber: ->
    if @options['countElem']
      if @options['countElem'] instanceof jQuery
        @$counter = @options['countElem']
        unless @$counter.html().length
          @options['countRenderFn'].call(this, @$counter, @maxlength)
      else
        throw 'option `countElem` is not a jQuery Object.'      
    else
      @$counter = $('<div />',
        class: @options['countClass']
        style: @options['style']
      )
      @options['countRenderFn'].call(this, @$counter, @maxlength)
      $parent = @$elem.parent()
      $parent.append(@$counter)
      $parent.append($('<div />', class: @options['clearClass']))


  render: ->
    @renderCountNumber()
    @$elem.trigger 'rendered:counter', this


  destroy: ->
    @$elem.data('ContentCounter', null)
    @$counter.remove() unless @options['countElem']
    @$elem.unbind @inputEventCallBack
    @$elem.trigger 'destroied:counter', this



Plugin = (options) ->
  this.each ->
    $this = $(this)
    data = $this.data('ContentCounter')
    options = $.extend {}, Making.ContentCounter.Default, $this.data(), options
    $this.data('ContentCounter', data = new ContentCounter(this, options)) unless data
    data.render()


$.fn.$contentCount = Plugin
$.fn.$contentCount.Constructor = ContentCounter


Making.ContentCounter = ($element, options) ->
  $element.$contentCount(options)


Making.ContentCounter.Default =
  maxlength: 140
  stopflow: true
  clearClass: 'clearfix'
  countClass: 'words-count'
  style: 'float: right;'
  countElem: false
  autoCountDown: true
  countRenderFn: ($counter, maxlength) ->
    $counter.html "0 / #{maxlength}"
  countDownFn: ($counter, length, maxlength) ->
    $counter.html "#{length} / #{maxlength}"
