json.id feeling.id.to_s
json.url url_wrapper(feeling.thing, feeling)
# json.html_url thing_feeling_url(feeling.thing, feeling)

json.created_at feeling.created_at
json.created_at_ago_in_words time_ago_in_words(feeling.created_at)

json.lovers_count feeling.lovers.count

if current_user
  json.loved feeling.lovers.include?(current_user)
end

json.score feeling.score
json.content feeling.content
json.photo_urls feeling.photos.map {|p| p.image.url}

json.author do
  json.partial! 'api/v1/users/user', user: feeling.author
end
