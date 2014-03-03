json.array! @groups do |group|
  json.id group.id.to_s
  json.url url_wrapper(group)
  json.html_url group_url(group)
  json.name group.name
  json.description group.description
end
