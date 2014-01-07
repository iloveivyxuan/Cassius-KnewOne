json.id @thing.id.to_s
json.title @thing.title
json.subtitle @thing.subtitle
json.stage @thing.stage
json.stage_text ::Thing::STAGES[@thing.stage]
if @thing.stage == :invest
  json.investors_count @thing.investors.count
  json.invest_amount invest_amount(@thing)
  json.invest_target @thing.target
  json.invest_unit '￥'
end
if price = price(@thing)
  json.min_price price
  json.price_unit '￥'
end
if @thing.self_run?
  json.kinds @thing.kinds do |kind|
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
json.photo_urls @thing.photos.map {|p| p.image.url}
json.fanciers_count @thing.fanciers.count
json.owners_count @thing.owners.count
json.reviews_count @thing.reviews.count
json.content @thing.content
json.created_at @thing.created_at
json.updated_at @thing.updated_at
if user_signed_in?
  json.fancied @thing.fancied?(current_user)
  json.owned @thing.fancied?(current_user)
end
json.author do
  json.id @thing.author.id.to_s
  json.url url_wrapper(@thing.author)
  json.avatar_url @thing.author.avatar.url
  json.name @thing.author.name
end
