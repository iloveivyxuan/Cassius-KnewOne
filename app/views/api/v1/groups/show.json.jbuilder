json.id @group.id.to_s
json.url url_wrapper(@group)
json.html_url group_url(@group)
json.avatar_url @group.avatar.url
json.members_url url_wrapper(@group, :members)
json.name @group.name
json.description @group.description
json.qualification @group.qualification
json.members_count @group.members_count
json.topics_count @group.topics_count
json.created_at @group.created_at
json.recent_topics do
  json.array! @topics, partial: 'api/v1/topics/topic', as: :topic
end
