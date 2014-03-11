Making.UserFuzzy = (source, target) ->
  users = new Bloodhound
    datumTokenizer: (datums) -> Bloodhound.tokenizers.whitespace(datums.value)
    queryTokenizer: Bloodhound.tokenizers.whitespace
    limit: 10
    remote:
      url: '/users/fuzzy.json?query=%QUERY'

  users.initialize()

  $(source).typeahead
    autoselect: true
    highlight: true
    minLength: 2
  ,
    name: 'users'
    displayKey: 'value',
    source: users.ttAdapter()
    templates:
      suggestion: HandlebarsTemplates['users/user']
      empty: '<em class="tt-no-suggestion">没有结果</em>'
  .on 'typeahead:selected', (event, suggestion, name) ->
    $(target).val suggestion.data