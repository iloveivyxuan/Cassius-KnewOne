json.id item.id.to_s

json.url url_wrapper(item)

json.quantity item.quantity
json.price_unit '￥'
json.price item.price
json.buyable item.buyable?
json.has_enough_stock item.has_enough_stock?

json.thing do
  json.partial! 'api/v1/things/thing', thing: item.thing
end

json.kind do
  json.partial! 'api/v1/things/kind', kind: item.kind
end
