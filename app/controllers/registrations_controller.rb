# -*- coding: utf-8 -*-
class RegistrationsController < Devise::RegistrationsController
  def update
    @user = User.find(current_user.id)
    logger.info params
    successfully_updated = if needs_password?(@user, params)
                             @user.update_with_password(params[:user])
                           else
                             if params[:user][:password].blank?
                               @user.assign_attributes(params[:user])
                               @user.valid?
                               @user.errors.add(:password, @user.password.blank? ? :blank : :invalid)
                               false
                             else
                               @user.update params[:user]
                             end
                           end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user)
    else
      render "edit"
    end
  end

  private
  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    !user.email.blank?
  end
end
