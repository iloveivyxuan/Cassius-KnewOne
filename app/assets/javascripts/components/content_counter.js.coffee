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
      @$elem.on 'overflow:counter', (e, context, length, maxlength) =>
        @$elem.val @$elem.val().substr 0, maxlength
        @updateCounter maxlength


  whenInput: (e) ->
    length = @$elem.val().length

    if @isOverflow = length > @maxlength
      @$elem.trigger 'overflow:counter', [this, length, @maxlength]
      @updateCounter(length) unless @options['stopflow']
    else
      @updateCounter(length)


  updateCounter: (length) ->
    @counter.html "#{length} / #{@maxlength}"
    @$elem.trigger 'updated:counter', [this, length]


  renderCountNumber: ->
    if @options['counter']
      @counter = @options['counter']
    else
      @counter = $('<div />',
        class: 'words-count'
        style: 'float: right',
        html: "0 / #{@maxlength}"
      )

      $parent = @$elem.parent()
      $parent.append(@counter)
      $parent.append($('<div />', class: @options['clearClass']))


  render: ->
    @renderCountNumber()
    @$elem.trigger 'rendered:counter', this


  destroy: ->
    @$elem.data('ContentCounter', null)
    @counter.remove() unless @options['counter']
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
  format: '${+} / $maxlength'
  stopflow: true
  clearClass: 'clearfix'