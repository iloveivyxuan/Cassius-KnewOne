json.array!(@comments) do |comment|
  json.id comment.id.to_s
  json.url url_wrapper(comment.post, comment)
  json.content sanitize(comment.content)
  json.created_at_ago_in_words time_ago_in_words(comment.created_at)
  json.created_at comment.created_at

  json.author do
    json.id comment.author.id.to_s
    json.url url_wrapper(comment.author)
    json.avatar_url comment.author.avatar.url
    json.name comment.author.name
  end
end
