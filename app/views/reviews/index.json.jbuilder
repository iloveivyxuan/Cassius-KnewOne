json.array!(@reviews) do |review|
  json.title review.title
  json.score review.score
  json.content review.content
  json.author do
    json.avatar review.author.avatar.url(:small)
    json.id review.author.id
    json.name review.author.name
  end
end
