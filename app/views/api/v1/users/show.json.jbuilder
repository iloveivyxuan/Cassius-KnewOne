json.id @user.id.to_s
json.name @user.name
json.rank @user.rank
json.progress_to_next_rank @user.progress.to_i
json.location @user.location
json.description @user.description
json.gender @user.gender
json.categories @user.categories do |c|
  json.partial! 'api/v1/categories/category', category: c
end
json.fancies_count @user.fancies.count
json.fancies_url url_wrapper(@user, action: :fancies)
json.things_count @user.things.count
json.things_url url_wrapper(@user, action: :things)
json.owns_count @user.owns.count
json.owns_url url_wrapper(@user, action: :owns)
json.reviews_count @user.reviews.count
json.reviews_url url_wrapper(@user, action: :reviews)
json.groups_count @user.groups_count
json.groups_url url_wrapper(@user, action: :groups)
json.followings_count @user.followings_count
json.followings_url url_wrapper(@user, action: :followings)
json.followers_count @user.followers_count
json.followers_url url_wrapper(@user, action: :followers)
json.activities_url url_wrapper(user, action: :activities)
