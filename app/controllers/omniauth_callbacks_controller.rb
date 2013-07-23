# -*- coding: utf-8 -*-
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ApplicationHelper

  def callback
    omniauth = request.env['omniauth.auth']

    if user = User.find_by_omniauth(omniauth)
      # Auth already bound
      if user_signed_in? && user.id != current_user.id
        return redirect_back_or root_path, :error => t('devise.omniauth_callbacks.bounded', kind: omniauth.provider)
      end

      user.update_from_omniauth(omniauth)
      sign_in user
      redirect_back_or root_path, :notice => t('devise.omniauth_callbacks.success', kind: omniauth.provider)
    elsif user_signed_in?
      current_user.auths<< Auth.from_omniauth(omniauth)
      current_user.update_from_omniauth(omniauth)
      redirect_to after_sign_in_path_for(current_user)
    else
      user = User.create_from_omniauth(omniauth)
      user.update_from_omniauth(omniauth)
      sign_in user
      # redirect_back_or edit_user_registration_path(:new => true)
      redirect_back_or root_path, :notice => t('devise.omniauth_callbacks.success', kind: omniauth.provider)
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
