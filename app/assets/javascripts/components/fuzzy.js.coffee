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


Making.GroupFuzzy = (source, target, current_user=true) ->
  groups = new Bloodhound
    datumTokenizer: (datums) -> Bloodhound.tokenizers.whitespace(datums.value)
    queryTokenizer: Bloodhound.tokenizers.whitespace
    limit: 10
    remote:
      url: '/groups/fuzzy.json?query=%QUERY&current_user=' + current_user

  groups.initialize()

  $(source).typeahead
    autoselect: true
    highlight: true
    minLength: 1
  ,
    name: 'groups'
    displayKey: 'value',
    source: groups.ttAdapter()
    templates:
      suggestion: HandlebarsTemplates['groups/group']
      empty: '<em class="tt-no-suggestion">没有结果</em>'
  .on 'typeahead:selected', (event, suggestion, name) ->
    $(target).val suggestion.data

Making.TagFuzzy = (source, target) ->
  tags = new Bloodhound
    datumTokenizer: (datums) -> Bloodhound.tokenizers.whitespace(datums.value)
    queryTokenizer: Bloodhound.tokenizers.whitespace
    limit: 10
    remote:
      url: '/tags/fuzzy.json?query=%QUERY'

  tags.initialize()

  $(source).typeahead
    autoselect: true
    highlight: true
    minLength: 2
  ,
    name: 'tags'
    displayKey: 'value',
    source: tags.ttAdapter()
    templates:
      suggestion: HandlebarsTemplates['tags/tag']
      empty: '<em class="tt-no-suggestion">没有结果</em>'
  .on 'typeahead:selected', (event, suggestion, name) ->
    $(target).val suggestion.data

Making.AtUser = (element) ->
  $(element).atwho
    at: "@"
    callbacks:
      remote_filter: (query, callback) ->
        if query.length > 0
          $.getJSON "/users/fuzzy.json",
            query: query
          , (data) ->
            usernames = []
            data.forEach (e) ->
              usernames.push name: e.value
              return
            callback usernames
            return
          return
