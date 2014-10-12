(($) ->
  $.fn.china_city = () ->
    @each ->
      $selects = $(@).find('.city-select')
      $selects
      .unbind('change') # 避免多次绑定change事件
      .change ->
        $this = $(@)
        select_index = $selects.index($this)+1
        select = $selects.eq(select_index)
        # clear children's options
        $selects.slice($selects.index(@) + 1).html('')
        # when select value not empty
        if select[0] and $(@).val()
          $.get "/china_city/" + $(@).val(), (data) ->
            result = eval(data)
            options = select[0].options
            $.each result, (i, item) -> options.add new Option(item[0], item[1])
            select.change()

  $ ->
    $('.city-group').china_city()
)(jQuery)
