case activity.reference.class
  when Thing
    json.partial! "hell/activities/thing_comment", activity: activity
  when Review
    json.partial! "hell/activities/review_comment", activity: activity
  when Topic
    json.partial! "hell/activities/topic_comment", activity: activity
end
