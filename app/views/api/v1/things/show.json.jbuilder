thing_stage = stage(@thing)

json.id @thing.id.to_s
json.title @thing.title
json.subtitle @thing.subtitle
json.stage thing_stage
json.stage_text ::Thing::STAGES[thing_stage]
json.categories @thing.categories do |c|
  json.partial! 'api/v1/categories/category', category: c
end
if price = price(@thing)
  json.min_price price
  json.price_unit '￥'
end
if @thing.self_run?
  json.has_stock @thing.has_stock?
  json.kinds @thing.kinds do |kind|
    json.partial! 'api/v1/things/kind', kind: kind
  end
end
json.official_site_url @thing.official_site
json.html_url thing_url(@thing)
json.reivews_url url_wrapper(@thing, :reviews)
json.comments_url url_wrapper(@thing, :comments)
json.cover_url @thing.cover.url
json.photo_urls @thing.photos.map {|p| p.image.url}
json.fanciers_count @thing.fanciers_count
json.owners_count @thing.owners_count
json.reviews_count @thing.reviews_count
json.content sanitize(@thing.content)
json.created_at @thing.created_at
json.updated_at @thing.updated_at
if current_user
  json.fancied @thing.fancied?(current_user)
  json.owned @thing.owned?(current_user)
end
json.author do
  json.partial! 'api/v1/users/user', user: @thing.author
end
