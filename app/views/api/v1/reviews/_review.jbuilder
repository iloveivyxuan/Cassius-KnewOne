json.id review.id.to_s
json.url url_wrapper(review.thing, review)
json.html_url thing_review_url(review.thing, review)

json.lovers_count review.lovers.count
json.comments_count review.comments.count
json.comments_url url_wrapper(review.thing, review, :comments)

json.title review.title
json.score review.score
json.summary content_summary(review)

if current_user
  json.loved review.lovers.include?(current_user)
end

json.author do
  json.partial! 'api/v1/users/user', user: review.author
end
