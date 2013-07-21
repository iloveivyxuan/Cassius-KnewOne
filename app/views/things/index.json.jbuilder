json.array!(@things) do |thing|
  present thing do |tp|
    json.(tp, :title)
    json.(tp, :subtitle)
    json.url thing_url(tp.thing)
    json.photo tp.photo_url(:huge)
    json.(tp, :content)
    json.(tp.thing, :price_unit)
    json.(tp.thing, :price)
    json.set! :author do
      json.avatar tp.author.avatar.url
      json.user_id tp.author.id
      json.name tp.author.name
    end
  end
end
