json.title @review.title
json.score @review.score
json.content @review.content
json.set! :author do
  json.avatar @review.author.avatar.url(:small)
  json.id @review.author.id
  json.name @review.author.name
end
json.comments @review.comments do |comment|
  json.content comment.content
  json.author do
    json.avatar comment.author.avatar.url(:small)
    json.id comment.author.id
    json.name comment.author.name
  end
end
