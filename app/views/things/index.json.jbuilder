json.array!(@things) do |thing|
  json.(thing, :id)
  json.title thing_title(thing)
  json.url thing_path(thing)
  json.price thing_price(thing)
  json.photo_main thing.photos.first.url(:middle)
end
