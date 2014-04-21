if thing = activity.reference
  json.type activity.type
  json.created_at activity.created_at
  json.source_identity activity.source_union

  json.thing do
    json.partial! 'api/v1/things/thing', thing: thing
  end

  json.user do
    json.partial! 'api/v1/users/user', user: activity.user
  end
end
