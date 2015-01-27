class Progressable
  constructor: (elem, @options) ->
    @$elem = $(elem)
    throw 'Nothing selected' unless @$elem.length
    @render()
    @widthInt = 0
    @options['initFn']?.call(this)


  copyStyleToWrapper: ->
    needStyles = ['float', 'display']
    targetStyles = {}
    $.each needStyles, (i, key) =>
      value = @$elem.css(key)
      targetStyles[key] = value

    @$wrapper.css targetStyles


  renderWrapper: ->
    @$elem.wrap '<div class="progressable-wrapper" />'
    @$wrapper = @$elem.parent()
    @copyStyleToWrapper()


  renderProgressBar: ->
    @$progress = $('<div class="progressable-progress-bar" />')
    @$wrapper.append(@$progress)


  renderText: ->
    @$text = $('<div class="progressable-text" />')
    @$text.html "0%"
    @$wrapper.append(@$text)


  render: ->
    @renderWrapper()
    @renderProgressBar()
    @renderText() if @options['withText']

    @$elem.attr 'disabled', 'disabled' if @options['disabled']


  updateText: (widthInt) ->
    @$text?.animate left: "#{widthInt}%", queue: false
    @$text.html "#{widthInt}%"


  start: ->
    interval = setInterval =>
      return if parseInt(Math.random() * 10) % 2 == 0
      return clearInterval(interval) if @widthInt == 100
      min = 5
      max = 100 - @widthInt
      max = if max > 40 then (Math.random() * (40 - 20) + 20) else max
      @inc Math.random() * (max - min) + min
    , @options['progressInterval']


  inc: (width) ->
    @set @widthInt + parseInt(width)


  set: (width) ->
    widthInt = parseInt width
    widthInt = 100 if widthInt > 100
    @$progress.animate width: "#{widthInt}%", queue: false, =>
      switch widthInt
        when 0 then @stop()
        when 100 then @done()
    @updateText(widthInt) if @options['withText']

    @widthInt = widthInt



  stop: ->
    @$elem.trigger 'stop:progress', [this]
    @remove() if @options['stopThenRemove']



  done: ->
    @$elem.trigger 'done:progress', [this]
    @remove() if @options['doneThenRemove']



  remove: ->
    @$progress.fadeOut 300, =>
      @$elem.trigger 'remove:progress', [this]
      @$elem.unwrap()
      @$progress.remove()
      @$text?.remove()
      @$elem.removeData 'progressable'
      @$elem.removeAttr('disabled') if @options['disabled']




Plugin = (options) ->
  this.each ->
    $this = $(this)
    data  = $this.data('progressable')
    if Object.prototype.toString.call(options) == '[object String]'
      if data
        data[options]?.call(data)
    else      
      options = $.extend {}, Default, options
      $this.data('progressable', data = new Progressable(this, options)) unless data



$.fn.$progress = Plugin
$.fn.$progress.Constructor = Progressable



Default = {
  disabled: true
  stopThenRemove: true
  doneThenRemove: true
  withText: true
  progressInterval: 400
}



$.fn.$progress.Default = Default


Making.Progressable = ($element, options) ->
  $element.$progress(options)
  [$element, $element.data('progressable')]