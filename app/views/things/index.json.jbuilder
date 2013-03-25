json.array!(@things) do |thing|
  json.(thing, :title)
  json.url thing_url(thing)
  json.(thing, :shop)
  json.(thing, :price_unit)
  json.(thing, :price)
end
