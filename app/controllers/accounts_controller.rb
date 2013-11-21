# -*- coding: utf-8 -*-
class AccountsController < Devise::RegistrationsController
  prepend_before_filter :authenticate_user!
  layout 'settings'

  def update
    successfully_updated = if needs_password?(current_user, params)
                             current_user.update_with_password(params[:user])
                           else
                             if params[:user][:password].blank?
                               current_user.assign_attributes(params[:user])
                               current_user.valid?
                               current_user.errors.add(:password, current_user.password.blank? ? :blank : :invalid)
                               false
                             else
                               current_user.update_attributes params[:user]
                             end
                           end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in current_user, :bypass => true
      redirect_to edit_settings_account_path
    else
      render "accounts/edit"
    end
  end

  def edit

  end

  private
  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.email.present? && user.encrypted_password.present?
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= current_user
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end
end
