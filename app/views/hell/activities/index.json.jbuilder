json.array! @activities do |activity|
  if activity.reference
    json.partial! "hell/activities/#{activity.type}", activity: activity
  end
end
