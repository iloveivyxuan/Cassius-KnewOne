class SessionsController < Devise::SessionsController
  layout 'oauth'
  skip_before_action :require_not_blocked

  before_action only: [:new] do
    session[:previous_url] = params[:redirect_from] if params[:redirect_from].present?
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)

    respond_to do |format|
      if @error = self.resource.nil?
        format.html { redirect_to new_user_session_path, flash: {error: true} }
        format.js
      else
        set_flash_message(:notice, :signed_in) if is_flashing_format?
        sign_in(resource_name, resource)
        yield resource if block_given?

        format.html { redirect_to after_sign_in_path_for(resource) }
        format.js do
          @location = after_sign_in_path_for(resource)
        end
      end
    end
  end

  # bind oauth
  after_action only: :create do
    if session[:omniauth].present? && !@error
      current_user.auths<< Auth.new(session[:omniauth])
      current_user.update_from_omniauth(session[:omniauth])

      session.delete :omniauth
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :remember_me)
  end

  def after_sign_out_path_for(resource_name)
    root_path
  end
end
