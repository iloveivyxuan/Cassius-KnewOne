if @things
  json.things @things, partial: 'api/v1/things/thing', as: :thing
end

if @users
  json.users @users, partial: 'api/v1/users/user', as: :user
end
