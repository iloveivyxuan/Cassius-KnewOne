class SessionsController < Devise::SessionsController
  layout 'oauth'
  skip_before_action :require_not_blocked

  before_action only: [:new] do
    session[:previous_url] = params[:redirect_from] if params[:redirect_from].present?
  end

  # bind oauth
  after_action :bind_omniauth, only: :create

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

        format.html { redirect_back_or after_sign_in_path_for(resource) }
        format.js do
          @location = after_sign_in_path_for(resource)
        end
      end
    end
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :remember_me)
  end

  # def redirect_back_or(path, flash = {})
  #   url = params[:redirect_from].present? ? params[:redirect_from] : path # Avoiding querystring like redirect_from=&
  #   redirect_to(url, flash)
  # end

  def after_sign_out_path_for(resource_name)
    root_path
  end
end
