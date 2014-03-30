json.array! @members do |member|
  json.role member.role
  json.created_at member.created_at

  json.partial! 'api/v1/users/user', user: member.user
end
