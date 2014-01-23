json.id current_user.id.to_s
json.name current_user.name
json.rank current_user.rank
json.progress_to_next_rank current_user.progress.to_i
json.location current_user.location
json.description current_user.description
json.fancies_count current_user.fancies.count
json.fancies_url url_wrapper(current_user, action: :fancies)
json.things_count current_user.things.count
json.things_url url_wrapper(current_user, action: :things)
json.owns_count current_user.owns.count
json.owns_url url_wrapper(current_user, action: :owns)
json.reviews_count current_user.reviews.count
json.reviews_url url_wrapper(current_user, action: :reviews)
