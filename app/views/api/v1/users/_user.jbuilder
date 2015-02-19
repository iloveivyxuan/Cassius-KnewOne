json.id user.id.to_s
json.url url_wrapper(user)
json.html_url user_url(user)
json.avatar_url user.avatar.url
json.name user.name
json.fancies_count user.fancies_count
json.fancies_url url_wrapper(user, action: :fancies)
json.things_count user.things_count
json.things_url url_wrapper(user, action: :things)
json.owns_count user.owns_count
json.owns_url url_wrapper(user, action: :owns)
json.reviews_count user.reviews_count
json.reviews_url url_wrapper(user, action: :reviews)
json.groups_count user.groups_count
json.groups_url url_wrapper(user, action: :groups)
json.followings_count user.followings_count
json.followings_url url_wrapper(user, action: :followings)
json.followers_count user.followers_count
json.followers_url url_wrapper(user, action: :followers)
json.activities_url url_wrapper(user, action: :activities)
if current_user
  json.followed user.followed?(current_user)
  json.following current_user.followed?(user)
end
