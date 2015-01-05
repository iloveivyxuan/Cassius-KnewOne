class PasswordsController < Devise::PasswordsController
  layout 'oauth'
  skip_before_action :require_not_blocked

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    respond_to do |format|
      if @success = successfully_sent?(resource)
        format.html { redirect_back_or root_path }
        format.js
      else
        format.html { render 'new' }
        format.js
      end
    end
  end
end
