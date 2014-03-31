review = activity.reference
if thing = review.thing
  json.type activity.type
  json.created_at activity.created_at

  json.review do
    json.partial! 'api/v1/reviews/review', review: review
  end

  json.thing do
    json.partial! 'api/v1/things/thing', thing: thing
  end

  json.user do
    json.partial! 'api/v1/users/user', user: activity.user
  end
end
