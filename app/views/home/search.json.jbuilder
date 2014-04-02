if @things
  json.things @things do |thing|
    json.title thing.title
    json.subtitle thing.subtitle
    json.url thing_url(thing)
    json.photo thing.cover.url(:huge)
    json.content thing.content
    json.price_unit thing.price_unit
    json.price thing.price
    json.stage thing.stage
    json.buy_url buy_thing_url(thing) unless thing.shop.blank?
    json.author do
      json.avatar thing.author.avatar.url
      json.url user_url(thing.author)
      json.id thing.author.id
      json.name thing.author.name
    end
  end
end

if @users
  json.users @users do |user|
    json.id user.id.to_s
    json.url user_url(user)
    json.avatar_url user.avatar.url
    json.name user.name
  end
end
