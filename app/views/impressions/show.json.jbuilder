json.(@impression, :state, :description, :score)
json.tags @impression.tag_names
json.recent_tags @recent_tags.map(&:name)
json.popular_tags @popular_tags.map(&:name)
