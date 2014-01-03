json.array!(@things) do |thing|
  json.title thing.title
  json.subtitle thing.subtitle
  json.url url_wrapper(thing)
  json.photo thing.cover.url(:huge)
  json.stage thing.stage
  json.author do
    json.avatar thing.author.avatar.url
    json.id thing.author.id
    json.name thing.author.name
  end
end
