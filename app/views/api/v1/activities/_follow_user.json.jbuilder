json.id activity.id.to_s
json.type activity.type
json.created_at activity.created_at
json.source_identity activity.source_union

json.following do
  json.partial! 'api/v1/users/user', user: activity.reference
end

json.user do
  json.partial! 'api/v1/users/user', user: activity.user
end
