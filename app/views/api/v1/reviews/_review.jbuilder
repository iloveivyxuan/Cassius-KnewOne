json.id review.id.to_s
json.url url_wrapper(review.thing, review)

json.lovers_count review.lovers.count
json.foes_count review.foes.count
json.comments_count review.comments.count

json.title review.title
json.score review.score
json.summary content_summary(review)
