json.type activity.type
json.created_at activity.created_at

json.thing do
  json.partial! 'api/v1/things/thing', thing: activity.reference
end

json.user do
  json.partial! 'api/v1/users/user', user: activity.user
end
