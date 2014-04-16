review = activity.reference
if thing = review.thing
  json.type activity.type
  json.created_at activity.created_at

  json.review do
    json.id review.id.to_s
    json.title review.title
    json.html_url thing_review_url(thing, review)
    json.author do
      json.id review.author.id.to_s
      json.name review.author.name
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
