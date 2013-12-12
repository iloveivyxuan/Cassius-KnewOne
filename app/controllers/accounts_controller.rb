# -*- coding: utf-8 -*-
class AccountsController < Devise::RegistrationsController
  prepend_before_action :authenticate_user!
  layout 'settings'

  def update
    successfully_updated = if needs_password?(current_user, params)
                             current_user.update_with_password(account_update_params)
                           else
                             current_user.assign_attributes(account_update_params)
                             if params[:user][:password].blank?
                               current_user.valid?
                               current_user.errors.add(:password, current_user.password.blank? ? :blank : :invalid)
                               false
                             else
                               current_user.save
                             end
                           end

    if successfully_updated
      set_flash_message :notice, :updated
      # Sign in the user bypassing validation in case his password changed
      sign_in current_user, :bypass => true
      redirect_to edit_account_path, flash: {account: { status: 'success', text: '修改成功。' }}
    else
      render "accounts/edit"
    end
  end

  def edit
  end

  def email
    current_user.email = params[:user][:email]

    respond_to do |format|
      if current_user.save
        # devise will send confirmation email when user created, but sign up by oauth, it will not trigger
        # and there isn't satisfied with devise's reconfirmation condition,
        # so need invoke send send_confirmation_instructions here
        if current_user.email.blank? && current_user.unconfirmed_email.present?
          current_user.send_confirmation_instructions
        end

        format.html { redirect_to edit_account_path, flash: {email: { status: 'success', text: '修改成功，验证邮件已发送，请检查邮箱。' }} }
        format.js { render 'email' }
      else
        format.html { render 'accounts/edit' }
      end
    end
  end

  private
  # check if we need password to update user data
  # ie if password or email was changed
  # extend this as needed
  def needs_password?(user, params)
    user.encrypted_password.present?
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
