# -*- coding: utf-8 -*-
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ApplicationHelper

  def callback
    omniauth = request.env['omniauth.auth']

    if user = User.find_by_omniauth(omniauth)
      # Auth already bound
      if user_signed_in? && user.id != current_user.id
        return redirect_stored_or root_path, :error => t('devise.omniauth_callbacks.bounded', kind: omniauth.provider)
      end

      user.update_from_omniauth(omniauth)
      sign_in user

      redirect_to after_sign_in_path_for(user),
                  :notice => t('devise.omniauth_callbacks.success', kind: omniauth.provider),
                  :flash => {:show_set_email_modal => !user.has_fulfilled_email?}
    elsif user_signed_in?
      # must be
      current_user.auths<< Auth.from_omniauth(omniauth)
      current_user.update_from_omniauth(omniauth)
      redirect_back_or edit_account_path, flash: {oauth: { status: 'success', text: '绑定成功。' }}
    else
      user = User.create_from_omniauth(omniauth)
      user.update_from_omniauth(omniauth)
      sign_in user

      redirect_to after_sign_in_path_for(user),
                  :notice => t('devise.omniauth_callbacks.success', kind: omniauth.provider),
                  flash: {:show_set_email_modal => true}
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
