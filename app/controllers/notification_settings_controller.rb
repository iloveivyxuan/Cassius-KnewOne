class NotificationSettingsController < ApplicationController
  prepend_before_action :require_signed_in
  layout 'settings'
  skip_before_action :require_not_blocked

  def update
    respond_to do |format|
      if current_user.notification_setting.update(notification_setting_params)
        format.html { redirect_to edit_notification_settings_path }
        format.json { head :no_content }
      else
        format.html { render "notification_settings/edit" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  private

  def notification_setting_params
    params.require(:notification_setting).permit(NotificationSetting::TYPES.keys)
  end
end
