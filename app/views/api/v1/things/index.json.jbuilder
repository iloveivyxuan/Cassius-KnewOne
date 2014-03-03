json.array!(@things) do |thing|
  thing_stage = stage(thing)

  json.id thing.id.to_s
  json.title thing.title
  json.subtitle thing.subtitle
  json.url url_wrapper(thing)
  json.html_url thing_url(thing)
  json.reviews_url url_wrapper(thing, :reviews)
  json.comments_url url_wrapper(thing, :comments)
  json.cover_url thing.cover.url
  json.stage thing_stage
  json.stage_text ::Thing::STAGES[thing_stage]
  if thing.stage == :invest
    json.investors_count thing.investors.count
    json.invest_amount invest_amount(thing)
    json.invest_target thing.target
    json.invest_unit '￥'
  end
  if thing.self_run?
    json.has_stock thing.has_stock?
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
  json.fancier_ids thing.fanciers.map {|u| u.id.to_s}
  json.owner_ids thing.owners.map {|u| u.id.to_s}
  json.author do
    json.partial! 'api/v1/users/user', user: thing.author
  end
end
