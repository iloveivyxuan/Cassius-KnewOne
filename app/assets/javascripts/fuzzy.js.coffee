Making.HavenUserFuzzy = (source, target, help) ->
  $(source).autocomplete
    serviceUrl: '/users/fuzzy.json',
    minChars: 2,
    autoSelectFirst: true,
    onSelect: (suggestion) ->
      $(target).val suggestion.data
    onInvalidateSelection: ->
      $(help).text '无此用户'

Making.UserFuzzy = (input) ->
  $(input).autocomplete
    serviceUrl: '/users/fuzzy.json',
    minChars: 2,
    autoSelectFirst: true,
    onSelect: (suggestion) ->
      $(@).val suggestion.value
