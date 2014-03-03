json.id @group.id.to_s
json.url url_wrapper(@group)
json.html_url group_url(@group)
json.name @group.name
json.description @group.description
json.topics_count @group.topics.count
json.recent_topics do
  json.array! @topics, partial: 'api/v1/topics/topic', as: :topic
end
