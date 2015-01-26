json.(@impression, :fancied, :state, :description, :score)
json.tags @impression.tag_names
json.recent_tags @recent_tags.map(&:name)
json.popular_tags @popular_tags.map(&:name)

json.thing do
  json.(@thing, :title)
  json.cover_url @thing.cover.url(:square)
end
