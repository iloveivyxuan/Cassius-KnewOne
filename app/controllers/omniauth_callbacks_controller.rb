class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ApplicationHelper

  before_action do
    params[:redirect_from] = params[:state] if params[:state].present? && params[:state][0] == '/'
  end

  after_action :bind_omniauth

  def callback
    omniauth = request.env['omniauth.auth']

    if user = User.find_by_omniauth(omniauth)
      # Auth already bound
      if user_signed_in? && user.id != current_user.id
        return redirect_stored_or root_path, flash: {
            oauth: {
                status: 'danger', text: t('devise.omniauth_callbacks.bounded', kind: Auth::PROVIDERS[omniauth.provider])
            }
        }
      end

      user.update_from_omniauth(omniauth)
      user.remember_me = true
      sign_in user

      redirect_back_or after_sign_in_path_for(user),
                       :notice => t('devise.omniauth_callbacks.success', kind: omniauth.provider),
                       :flash => {:show_set_email_modal => !user.has_fulfilled_email?}
    elsif user_signed_in?
      # must be
      current_user.auths<< Auth.from_omniauth(omniauth)
      current_user.update_from_omniauth(omniauth)

      redirect_back_or edit_account_path, flash: {oauth: {status: 'success', text: '绑定成功。'}}
    else
      user = User.create_from_omniauth(omniauth)
      user.remember_me = true
      sign_in user

      FriendJoinedNotificationWorker.perform_async user.id.to_s

      redirect_to welcome_url,
                  :notice => t('devise.omniauth_callbacks.success', kind: omniauth.provider),
                  flash: {:show_set_email_modal => true}
    end
  end

  def callback_with_bind_flow
    omniauth = request.env['omniauth.auth']

    if user = User.find_by_omniauth(omniauth)
      # Auth already bound
      if user_signed_in? && user.id != current_user.id
        return redirect_stored_or root_path, flash: {
            oauth: {
                status: 'danger', text: t('devise.omniauth_callbacks.bounded', kind: Auth::PROVIDERS[omniauth.provider])
            }
        }
      end

      user.update_from_omniauth(omniauth)
      sign_in user

      redirect_back_or after_sign_in_path_for(user),
                       :notice => t('devise.omniauth_callbacks.success', kind: omniauth.provider),
                      :flash => {:show_set_email_modal => !user.has_fulfilled_email?}
    elsif user_signed_in?
      # must be
      current_user.auths<< Auth.from_omniauth(omniauth)
      current_user.update_from_omniauth(omniauth)
      redirect_back_or edit_account_path, flash: {oauth: {status: 'success', text: '绑定成功。'}}
    else
      session[:omniauth] = Auth.omniauth_to_auth(omniauth)

      redirect_to new_user_session_path(redirect_from: params[:redirect_from], from: 'oauth')
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
  alias_method :qq_connect, :callback
  alias_method :douban, :callback

  alias_method :wechat, :callback_with_bind_flow
  alias_method :bong, :callback_with_bind_flow
end
