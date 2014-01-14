json.id thing.id.to_s
json.title thing.title
json.subtitle thing.subtitle
json.url url_wrapper(thing)
json.reivews_url url_wrapper(thing, :reviews)
json.comments_url url_wrapper(thing, :comments)
json.cover_url thing.cover.url
json.stage thing.stage
json.stage_text ::Thing::STAGES[thing.stage]
if thing.stage == :invest
  json.investors_count thing.investors.count
  json.invest_amount invest_amount(thing)
  json.invest_target thing.target
  json.invest_unit '￥'
end
json.fanciers_count thing.fanciers.count
json.owners_count thing.owners.count
json.reviews_count thing.reviews.count
if price = price(thing)
  json.min_price price
  json.price_unit '￥'
end
json.created_at thing.created_at
json.updated_at thing.updated_at
if user_signed_in?
  json.fancied thing.fancied?(current_user)
  json.owned thing.fancied?(current_user)
end
