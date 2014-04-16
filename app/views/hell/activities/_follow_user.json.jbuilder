following = activity.reference

json.type activity.type
json.created_at activity.created_at

json.following do
  json.id following.id.to_s
  json.name following.name
end

json.user do
  json.id activity.user.id.to_s
  json.name activity.user.name
end
