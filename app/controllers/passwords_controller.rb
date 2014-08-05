class PasswordsController < Devise::PasswordsController
  layout 'oauth'
  skip_before_action :require_not_blocked
end
