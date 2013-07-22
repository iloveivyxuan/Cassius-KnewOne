json.array!(@things) do |thing|
  json.title thing.title
  json.subtitle thing.subtitle
  json.url thing_url(thing)
  json.photo thing.cover.url(:huge)
  json.content thing.content
  json.price_unit thing.price_unit
  json.price thing.price
  json.author do
    json.avatar thing.author.avatar.url
    json.id thing.author.id
    json.name thing.author.name
  end
end
