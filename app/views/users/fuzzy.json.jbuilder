json.suggestions @users do |u|
  json.data u.id.to_s
  json.value u.name
end
