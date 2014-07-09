json.id current_user.id.to_s
json.name current_user.name
json.avatar_url current_user.avatar.url
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

json.groups_count current_user.groups_count
json.groups_url url_wrapper(current_user, action: :groups)

json.followings_count current_user.followings_count
json.followings_url url_wrapper(current_user, action: :followings)

json.followers_count current_user.followers_count
json.followers_url url_wrapper(current_user, action: :followers)

json.activities_url url_wrapper(current_user, action: :activities)
