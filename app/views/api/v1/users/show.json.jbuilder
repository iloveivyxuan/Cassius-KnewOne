json.id @user.id.to_s
json.name @user.name
json.rank @user.rank
json.progress_to_next_rank @user.progress.to_i
json.location @user.location
json.description @user.description
json.fancies_count @user.fancies.count
json.fancies_url url_wrapper(@user, action: :fancies)
json.things_count @user.things.count
json.things_url url_wrapper(@user, action: :things)
json.owns_count @user.owns.count
json.owns_url url_wrapper(@user, action: :owns)
json.reviews_count @user.reviews.count
json.reviews_url url_wrapper(@user, action: :reviews)
