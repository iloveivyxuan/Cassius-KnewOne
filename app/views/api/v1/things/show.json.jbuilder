json.id @thing.id.to_s
json.title @thing.title
json.subtitle @thing.subtitle
json.stage @thing.stage
json.stage_text ::Thing::STAGES[@thing.stage]
json.official_site_url @thing.official_site
json.photo_urls @thing.photos.map {|p| p.image.url}
json.fanciers_count @thing.fanciers.count
json.owners_count @thing.owners.count
json.reviews_count @thing.reviews.count
json.price price(@thing)
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
