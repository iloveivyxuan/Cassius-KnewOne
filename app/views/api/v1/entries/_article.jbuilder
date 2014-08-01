json.lovers_count post.lovers_count

json.comments_count post.comments.size
json.comments_url url_wrapper(post, :comments)

json.content sanitize(post.content)

json.relate_things do
  json.array! entry.things, partial: 'api/v1/things/thing', as: :thing
end

json.author do
  json.partial! 'api/v1/users/user', user: post.author
end
