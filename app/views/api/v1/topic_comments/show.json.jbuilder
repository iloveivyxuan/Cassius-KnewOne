json.id @comment.id.to_s
json.content sanitize(@comment.content)
json.created_at_ago_in_words time_ago_in_words(@comment.created_at)
json.created_at @comment.created_at

json.author do
  json.partial! 'api/v1/users/user', user: @comment.author
end
