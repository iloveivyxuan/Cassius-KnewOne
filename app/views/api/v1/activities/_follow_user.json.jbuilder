json.type activity.type
json.created_at activity.created_at

json.following do
  json.partial! 'api/v1/users/user', user: activity.reference
end

json.user do
  json.partial! 'api/v1/users/user', user: activity.user
end
