class RegistrationsController < Devise::RegistrationsController
  skip_before_filter :verify_authenticity_token, :if => Proc.new { |c| c.request.format == 'application/json' }
  layout 'oauth'

  before_action only: [:create] do
    session[:previous_url] = params[:redirect_from] if params[:redirect_from].present?
  end

  # bind oauth
  after_action :bind_omniauth, only: :create

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
      redirect_to after_update_path_for(@user), flash: {account: {status: 'success', text: '修改成功。'}}
    else
      render "edit"
    end
  end

  def create
    params[:password_confirmation] = params[:password] # no need password confirmation when sign up

    build_resource(sign_up_params)

    respond_to do |format|
      if @success = resource.save
        yield resource if block_given?

        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
        end

        flash[:show_sign_up_modal] = true

        format.html { redirect_back_or welcome_url }
        format.js { @location = welcome_url }
        format.json { render json: resource, status: :created, location: resource }
      else
        clean_up_passwords resource

        format.html
        format.js do
          @error_fields = resource.errors.keys
          @messages = resource.errors.full_messages
        end
        format.json { render json: resource.errors, status: :unprocessable_entity }
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

  def user_params
    params.require(:user).permit(:location, :name, :site, :description, :email, :password, :password_confirmation)
  end

end
