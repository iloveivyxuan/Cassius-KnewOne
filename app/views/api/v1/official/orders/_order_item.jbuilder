json.quantity item.quantity
json.price item.price

json.thing do
  json.partial! 'api/v1/things/thing', thing: item.thing
end

json.kind do
  json.title item.kind_title
  json.single_price item.single_price
end
