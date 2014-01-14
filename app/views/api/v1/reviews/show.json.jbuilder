json.id @review.id.to_s
json.url url_wrapper(@thing, @review)

json.title @review.title
json.score @review.score
json.content sanitize(@review.content)

json.author do
  json.id @review.author.id.to_s
  json.url url_wrapper(@review.author)
  json.avatar_url @review.author.avatar.url
  json.name @review.author.name
end
