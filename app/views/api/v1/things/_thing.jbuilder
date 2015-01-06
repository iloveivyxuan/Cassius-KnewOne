json.id thing.id.to_s
json.title thing.title
json.subtitle thing.subtitle
json.url url_wrapper(thing)
json.html_url thing_url(thing)
json.reivews_url url_wrapper(thing, :reviews)
json.comments_url url_wrapper(thing, :comments)
json.cover_url thing.cover.url
json.stage thing.stage
json.stage_text ::Thing::STAGES[thing.stage]
json.fanciers_count thing.fanciers_count
json.owners_count thing.owners_count
json.reviews_count thing.reviews_count
json.categories thing.category_records do |c|
  json.partial! 'api/v1/categories/category', category: c
end
if price = price(thing)
  json.min_price price
  json.price_unit '￥'
end
if current_user
  json.fancied thing.fancied?(current_user)
  json.owned thing.owned?(current_user)
end
json.author do
  json.partial! 'api/v1/users/user', user: thing.author
end
json.created_at thing.created_at
json.updated_at thing.updated_at
