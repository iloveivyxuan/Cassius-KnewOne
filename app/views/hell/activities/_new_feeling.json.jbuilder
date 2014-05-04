feeling = activity.reference
if thing = feeling.thing
  json.type activity.type
  json.created_at activity.created_at

  json.feeling do
    json.id feeling.id.to_s

    json.author do
      json.id feeling.author.id.to_s
      json.name feeling.author.name
    end
  end

  json.thing do
    json.id thing.id.to_s
    json.title thing.title
    json.html_url thing_url(thing)
    json.author do
      json.id thing.author.id.to_s
      json.name thing.author.name
    end
  end

  json.user do
    json.id activity.user.id.to_s
    json.name activity.user.name
  end
end
