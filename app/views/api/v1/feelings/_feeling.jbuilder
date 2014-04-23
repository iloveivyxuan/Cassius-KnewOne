json.id feeling.id.to_s
json.url url_wrapper(feeling.thing, feeling)
# json.html_url thing_feeling_url(feeling.thing, feeling)

json.lovers_count feeling.lovers.count
json.foes_count feeling.foes.count

json.score feeling.score
json.content feeling.content
json.photo_urls feeling.photos.map {|p| p.image.url}

json.author do
  json.partial! 'api/v1/users/user', user: feeling.author
end
