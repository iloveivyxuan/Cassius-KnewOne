json.quantity item.quantity
json.price item.price

json.thing do
  json.id item.thing.id.to_s
  json.title item.thing.title
  json.subtitle item.thing.subtitle
  json.url url_wrapper(item.thing)
  json.html_url thing_url(item.thing)
  json.cover_url item.thing.cover.url
end

json.kind do
  json.title item.kind_title
  json.single_price item.single_price
end
