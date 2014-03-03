json.id user.id.to_s
json.url url_wrapper(user)
json.html_url user_url(user)
json.avatar_url user.avatar.url
json.name user.name
