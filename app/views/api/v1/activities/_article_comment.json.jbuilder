json.id activity.id.to_s
json.type 'article_comment'
json.created_at activity.created_at
json.created_at_ago_in_words time_ago_in_words(activity.created_at)
json.source_identity activity.source_union

#TODO: NYI

json.user do
  json.partial! 'api/v1/users/user', user: activity.user
end
