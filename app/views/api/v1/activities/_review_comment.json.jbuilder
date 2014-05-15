review = activity.reference
if thing = review.thing
  json.id activity.id.to_s
  json.type 'review_comment'
  json.created_at activity.created_at
  json.created_at_ago_in_words time_ago_in_words(activity.created_at)
  json.source_identity activity.source_union

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
