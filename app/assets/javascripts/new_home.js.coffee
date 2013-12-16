Making.HomePage =
  Init: ->
    $('#show_classic_form').click ->
        $('#classic_form')[if $('#classic_form').is(':hidden') then 'fadeIn' else 'fadeOut']('fast')