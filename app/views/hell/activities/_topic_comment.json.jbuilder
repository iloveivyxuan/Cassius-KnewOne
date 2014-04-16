topic = activity.reference
if group = topic.group
  json.type activity.type
  json.created_at activity.created_at

  json.topic do
    json.id topic.id.to_s
    json.title topic.title
    json.html_url group_topic_url(group, topic)
    json.author do
      json.id topic.author.id.to_s
      json.name topic.author.name
    end
  end

  json.group do
    json.id group.id.to_s
    json.name group.name
    json.html_url group_url(group)
  end

  json.user do
    json.id activity.user.id.to_s
    json.name activity.user.name
  end
end
