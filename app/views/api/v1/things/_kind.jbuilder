json.id kind.id.to_s
json.title kind.title
json.photo_index kind.photo_number
json.max_per_buy kind.max_per_buy
json.price kind.price
json.price_unit '￥'
json.stock kind.stock
json.sold kind.sold
json.stage kind.stage
if kind.stage == :ship
  json.estimates_at kind.estimates_at
end
