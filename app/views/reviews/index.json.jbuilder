json.array!(@reviews) do |review|
  json.(review, :id, :title)
end
