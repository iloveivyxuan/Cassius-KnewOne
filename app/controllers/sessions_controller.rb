# -*- coding: utf-8 -*-
class SessionsController < Devise::SessionsController
  layout 'oauth'

  before_action only: [:new] do
    session[:previous_url] = params[:redirect_from] if params[:redirect_from].present?
  end

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate(auth_options)

    return redirect_to new_user_session_path, flash: {error: true} if self.resource.nil?

    set_flash_message(:notice, :signed_in) if is_flashing_format?
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_with resource, :location => after_sign_in_path_for(resource)
  end

  private
  def user_params
    params.require(:user).permit(:email, :password, :remember_me)
  end
end
