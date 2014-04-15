case activity.reference.class
  when Thing
    json.partial! "api/v1/activities/thing_comment", activity: activity
  when Review
    json.partial! "api/v1/activities/review_comment", activity: activity
  when Topic
    json.partial! "api/v1/activities/topic_comment", activity: activity
end
