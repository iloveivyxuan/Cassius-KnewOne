json.(comment, :id)
json.content comment_content(comment)
json.created_time_tag time_ago_tag(comment.created_at)
json.can_destroy can?(:destroy, comment)
json.can_reply can?(:create, comment)

json.author do
  json.name comment.author.name
  json.url url_for(comment.author)
  json.photo_url comment.author.avatar.url
end
