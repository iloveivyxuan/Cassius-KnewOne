(($) ->
  $.fn.china_city = () ->
    @each ->
      $selects = $(@).find('.city-select')
      $selects
      .on 'change.city', ->
        $this = $(@)
        select_index = $selects.index($this)+1
        select = $selects.eq(select_index)
        # clear children's options
        $selects.slice($selects.index(@) + 1).each ->
          $(@).children().slice(1).remove()
        # when select value not empty
        if select[0] and $(@).val()
          $.get "/china_city/" + $(@).val(), (data) ->
            result = eval(data)
            options = select[0].options
            $.each result, (i, item) -> options.add new Option(item[0], item[1])

  $ ->
    ($cityGroup = $('.city-group')).length and $cityGroup.china_city()
)(jQuery)
