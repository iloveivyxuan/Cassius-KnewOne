json.id topic.id.to_s
json.url url_wrapper(topic.group, topic)
json.html_url group_topic_url(topic.group, topic)
json.title topic.title
json.content topic.content
json.comments_count topic.comments.count
json.comments_url url_wrapper(topic.group, topic, :comments)
json.author do
  json.partial! 'api/v1/users/user', user: topic.author
end
