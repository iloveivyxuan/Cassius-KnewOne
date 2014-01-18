json.array!(@things) do |thing|
  thing_stage = stage(thing)

  json.id thing.id.to_s
  json.title thing.title
  json.subtitle thing.subtitle
  json.url url_wrapper(thing)
  json.reivews_url url_wrapper(thing, :reviews)
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
  if user_signed_in?
    json.fancied thing.fancied?(current_user)
    json.owned thing.owned?(current_user)
  end
  json.author do
    json.id thing.author.id.to_s
    json.url url_wrapper(thing.author)
    json.avatar_url thing.author.avatar.url
    json.name thing.author.name
  end
end
