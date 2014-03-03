json.id @topic.id.to_s
json.html_url group_topic_url(@topic.group, topic)
json.title @topic.title
json.content @topic.content
json.comments_count @topic.comments.count
json.author do
  json.partial! 'api/v1/users/user', user: @topic.author
end
