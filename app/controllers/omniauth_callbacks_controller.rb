# -*- coding: utf-8 -*-
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ApplicationHelper

  def callback
    omniauth = request.env['omniauth.auth']

    if user = User.find_by_omniauth(omniauth)
      user.update_from_omniauth(omniauth)
      sign_in user
      redirect_back_or root_path
    elsif user_signed_in?
      current_user.auths<< Auth.from_omniauth(omniauth)
      user.update_from_omniauth(omniauth)
      redirect_to after_sign_in_path_for(current_user)
    else
      user = User.create_from_omniauth(omniauth)
      user.update_from_omniauth(omniauth)
      sign_in user
      redirect_back_or edit_user_registration_path(:new => true)
    end
  end

  def failure
    redirect_to root_path
  end

  # This is solution for existing accout want bind Google login but current_user is always nil
  # https://github.com/intridea/omniauth/issues/185
  def handle_unverified_request
    true
  end

  alias_method :weibo, :callback
  alias_method :twitter, :callback
end
