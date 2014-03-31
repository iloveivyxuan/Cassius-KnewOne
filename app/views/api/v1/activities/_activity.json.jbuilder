if activity.reference
  json.partial! "api/v1/activities/#{activity.type}", activity: activity
end
