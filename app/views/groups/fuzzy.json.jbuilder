json.array!(@groups) do |g|
  json.data g.id.to_s
  json.value g.name
  json.avatar g.avatar.url
end
