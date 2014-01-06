json.array!(@things) do |thing|
  json.id thing.id.to_s
  json.title thing.title
  json.subtitle thing.subtitle
  json.url url_wrapper(thing)
  json.cover_url thing.cover.url
  json.stage thing.stage
  json.stage_text ::Thing::STAGES[thing.stage]
  json.fanciers_count thing.fanciers.count
  json.owners_count thing.owners.count
  json.reviews_count thing.reviews.count
  json.price price(thing)
  json.created_at thing.created_at
  json.updated_at thing.updated_at
  if user_signed_in?
    json.fancied thing.fancied?(current_user)
    json.owned thing.fancied?(current_user)
  end
  json.author do
    json.id thing.author.id.to_s
    json.url url_wrapper(thing.author)
    json.avatar_url thing.author.avatar.url
    json.name thing.author.name
  end
end
