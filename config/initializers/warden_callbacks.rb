Warden::Manager.after_authentication do |user, auth, opts|
  user.log_activity :login_user, user, visible: false
end
