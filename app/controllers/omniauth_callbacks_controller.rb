# -*- coding: utf-8 -*-
class OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def all
    auth_data = request.env["omniauth.auth"]
    user = User.find_by_omniauth(auth_data)
    if user
      sign_in_and_redirect user
    elsif user_signed_in?
      # current_user.auths << Auth.from_omniauth(auth_data)
      # flash[:success] = "您与#{auth_data[:provider]}的绑定成功"
      # if id = cookies['interview_shared'] and interview = Interview.find(id)
      #   #Binding auth from Interviews#show, share the interview
      #   flash[:share] = current_user.auths?
      #   redirect_to topic_interview_path(interview.topic, interview)
      # else
      #   #Binding auth from Auths#index
      #   redirect_to user_auths_path(current_user)
      # end
    else
      user = User.create_from_omniauth(auth_data)
      sign_in_and_redirect user
    end
  end

  alias_method :weibo, :all
  alias_method :twitter, :all

end
