json.array!(@thing.comments) do |comment|
  json.content comment.content
  json.set! :author do
    json.avatar comment.author.avatar.url(:small)
    json.id comment.author.id
    json.name comment.author.name
  end
end
