json.id @thing.id.to_s
json.title @thing.title
json.subtitle @thing.subtitle
json.url thing_url(@thing)
json.categories @thing.categories.top_level.pluck(:name)
json.content @thing.content
json.price_unit @thing.price_unit
json.price @thing.price
json.photo @thing.cover.url(:huge)
json.stage @thing.stage
json.official_site @thing.official_site
json.buy_url buy_thing_url(@thing) unless @thing.shop.blank?
json.photos @thing.photos do |photo|
  json.url photo.image.url
end
json.author do
  json.avatar @thing.author.avatar.url(:small)
  json.id @thing.author.id
  json.name @thing.author.name
end
