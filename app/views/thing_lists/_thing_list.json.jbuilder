json.id thing_list.id.to_s
json.name thing_list.name
json.size thing_list.size
json.updated_at thing_list.updated_at
json.items thing_list.items do |item|
  json.id item.id.to_s
  json.thing_id item.thing_id.to_s
  json.order item.order
end
