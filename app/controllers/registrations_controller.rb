# -*- coding: utf-8 -*-
class RegistrationsController < Devise::RegistrationsController
  layout 'oauth', only: [:new, :create]

  def update
    @user = User.find(current_user.id)
    successfully_updated = if needs_password?(@user, user_params)
                             @user.update_with_password(user_params)
                           else
                             if params[:user][:password].blank?
                               @user.assign_attributes(user_params)
                               @user.valid?
                               @user.errors.add(:password, @user.password.blank? ? :blank : :invalid)
                               false
                             else
                               @user.update user_params
                             end
                           end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to after_update_path_for(@user), flash: {account: { status: 'success', text: '修改成功。' }}
    else
      render "edit"
    end
  end

  private
  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.encrypted_password.present?
  end

  def user_params
    params.require(:user).permit(:location, :name, :site, :nickname, :description, :email, :password, :password_confirmation)
  end
end
