class AccountsController < Devise::RegistrationsController
  prepend_before_action :require_signed_in
  layout 'settings'
  after_action :store_location, only: [:edit]
  skip_before_action :require_not_blocked

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
      current_user.clean_up_passwords
      # set password will change this field
      current_user.encrypted_password = nil if current_user.encrypted_password_was.nil?

      render "accounts/edit"
    end
  end

  def edit
  end

  def email
    email_changed = (params[:user][:email].present? &&
                     params[:user][:email] != current_user.email)

    respond_to do |format|
      if current_user.update(email_params)
        format.js { render 'email' }

        if email_changed
          # devise will send confirmation email when user created, but sign up by oauth, it will not trigger
          # and there isn't satisfied with devise's reconfirmation condition,
          # so need invoke send send_confirmation_instructions here
          if current_user.email.blank? && current_user.unconfirmed_email.present?
            current_user.send_confirmation_instructions
          end

          format.html { redirect_back_or edit_account_path, flash: {email: { status: 'success', text: '修改成功，验证邮件已发送，请检查邮箱。' }} }
        else
          format.html { render 'accounts/edit' }
        end
      else
        format.html { render 'accounts/edit' }
        format.js { render 'accounts/email_fail' }
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

  def email_params
    params.require(:user).permit(:email, :accept_edm)
  end
end
