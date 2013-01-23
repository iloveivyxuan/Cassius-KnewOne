json.(review, :id, :title, :content)
json.created_time_tag time_ago_tag(review.created_at)

json.author do
  json.name review.author.name
  json.url url_for(review.author)
  json.photo_url review.author.avatar.url
end
