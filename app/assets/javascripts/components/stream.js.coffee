do (exports = Making) ->

  class exports.View.Stream

    constructor: (element) ->
      @$el       = $(element)
      @$content  = $('.stream_content', @$el)
      @$btn_load = $('.stream_more', @$el)
      @$hint     = @$btn_load.find('.fa')
      @page      = 1
      @per       = @$content.children().length || 1
      @status    = ''

      _.bindAll(this, 'render', 'load', 'success', 'fail')

      @$el
        .on 'click', '.stream_more', @load

    render: ->

      switch @status
        when 'success'
          if @page is 1
            @$btn_load.removeClass('hidden')

        when 'nocontent'
          if @page is 1
            @$content.next('.nomore').removeClass('hidden')
          @$btn_load.disable().text('没有更多')

        when 'fail'
          @$btn_load.text('出错了，请稍候再试。')

    load: (event) ->
      event.preventDefault()

      @$hint.addClass('fa-spin')

      $
        .ajax
          url: @$content.data('url')
          data:
            page: @page + 1
            per: @per
          dataType: 'html'
          contentType: 'application/x-www-form-urlencoded;charset=UTF-8'
        .done @success
        .fail @fail

      return

    success: (data, status, xhr) ->
      @status = status
      if xhr.status is 200
        if data.length
          @$content.append(data)
        else
          @status = 'nocontent'

        @page += 1
        @$hint.removeClass('fa-spin')
        @render()

    fail: (xhr, status, error) ->
      @status = status
      @render()

  return
