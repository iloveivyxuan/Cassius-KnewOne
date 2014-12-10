json.id @review.id.to_s
json.html_url thing_review_url(@thing, @review)
json.partial! 'api/v1/reviews/review', review: @review

json.lovers_count @review.lovers.count
json.comments_count @review.comments.count
json.comments_url url_wrapper(@review.thing, @review, :comments)

if current_user
  json.loved @review.lovers.include?(current_user)
end

json.title @review.title
json.score @review.score
json.content sanitize(@review.content)

json.author do
  json.partial! 'api/v1/users/user', user: @review.author
end
