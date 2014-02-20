json.id item.id.to_s

json.url api_v1_account_cart_item_url(item)

json.quantity item.quantity
json.price_unit '￥'
json.price item.price
json.buyable item.buyable?
json.has_enough_stock item.has_enough_stock?

json.thing do
  json.id item.thing.id.to_s
  json.title item.thing.title
  json.subtitle item.thing.subtitle
  json.url url_wrapper(item.thing)
  json.html_url thing_url(item.thing)
  json.cover_url item.thing.cover.url
end

json.kind do
  json.id item.kind.id.to_s
  json.title item.kind.title
  json.stage item.kind.stage
  json.stock item.kind.stock
  json.max_per_buy item.kind.max_per_buy
  json.price item.kind.price
  json.price_unit '￥'
  json.stock item.kind.stock
  if item.kind.stage == :ship
    json.estimates_at item.kind.estimates_at
  end
end
