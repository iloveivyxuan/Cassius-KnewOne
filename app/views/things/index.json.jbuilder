json.array!(@things) do |thing|
  present thing do |tp|
    json.(tp, :title)
    json.url thing_url(tp.thing)
    json.photo tp.photo_url(:huge)
    json.(tp, :content)
    json.(tp.thing, :price_unit)
    json.(tp.thing, :price)
  end
end
