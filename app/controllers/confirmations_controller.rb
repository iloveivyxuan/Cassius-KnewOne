class ConfirmationsController < Devise::ConfirmationsController
  # POST /resource/confirmation
  def create
    if user_signed_in?
      current_user.send_confirmation_instructions
      self.resource = current_user
    else
      self.resource = resource_class.send_confirmation_instructions(resource_params)
    end

    yield resource if block_given?

    if successfully_sent?(resource)
      respond_to do |format|
        format.html { redirect_stored_or after_resending_confirmation_instructions_path_for(resource_name) }
        format.js
      end
    else
      respond_with(resource)
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])
    yield resource if block_given?

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_flashing_format?
      respond_with_navigational(resource) { redirect_to after_confirmation_path_for(resource_name, resource),
                                                        flash: {show_confirmation_modal: true} }
    else
      redirect_to root_path, alert: '认证码过期或无效'
    end
  end
end
