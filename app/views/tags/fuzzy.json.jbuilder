json.array!(@tags) do |t|
  json.data t.id.to_s
  json.value t.name
end
