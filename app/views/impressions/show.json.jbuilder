json.(@impression, :state, :description, :score)
json.tags @impression.tags.pluck(:name)
