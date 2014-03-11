json.array!(@users) do |u|
  json.data u.id.to_s
  json.value u.name
  json.avatar u.avatar.url
end
