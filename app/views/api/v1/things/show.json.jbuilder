thing_stage = stage(@thing)

json.id @thing.id.to_s
json.title @thing.title
json.subtitle @thing.subtitle
json.stage thing_stage
json.stage_text ::Thing::STAGES[thing_stage]
if price = price(@thing)
  json.min_price price
  json.price_unit '￥'
end
if @thing.self_run?
  json.has_stock @thing.has_stock?
  json.kinds @thing.kinds do |kind|
    json.id kind.id.to_s
    json.title kind.title
    json.photo_index kind.photo_number
    json.max_per_buy kind.max_per_buy
    json.price kind.price
    json.price_unit '￥'
    json.stock kind.stock
    json.sold kind.sold
    json.stage kind.stage
    if kind.stage == :ship
      json.estimates_at kind.estimates_at
    end
  end
end
json.official_site_url @thing.official_site
json.html_url thing_url(@thing)
json.reivews_url url_wrapper(@thing, :reviews)
json.comments_url url_wrapper(@thing, :comments)
json.photo_urls @thing.photos.map {|p| p.image.url}
json.fanciers_count @thing.fanciers.count
json.owners_count @thing.owners.count
json.reviews_count @thing.reviews.count
json.content sanitize(@thing.content)
json.created_at @thing.created_at
json.updated_at @thing.updated_at
json.author do
  json.partial! 'api/v1/users/user', user: @thing.author
end
