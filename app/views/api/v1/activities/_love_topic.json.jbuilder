topic = activity.reference
if group = topic.group
  json.id activity.id.to_s
  json.type activity.type
  json.created_at activity.created_at
  json.created_at_ago_in_words time_ago_in_words(activity.created_at)
  json.source_identity activity.source_union

  json.topic do
    json.partial! 'api/v1/topics/topic', topic: topic
  end

  json.group do
    json.partial! 'api/v1/groups/group', group: group
  end

  json.user do
    json.partial! 'api/v1/users/user', user: activity.user
  end
end
