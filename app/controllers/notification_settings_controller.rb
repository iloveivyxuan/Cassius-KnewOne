class NotificationSettingsController < ApplicationController
  prepend_before_action :require_signed_in
  layout 'settings'

  def update

    respond_to do |format|
      if current_user.notification_setting.update(notification_setting_params)
        format.html { redirect_to edit_profile_path, flash: {profile: { status: 'success', text: '修改成功。' }} }
        format.json { head :no_content }
      else
        format.html { render "profiles/edit" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  private

  def notification_setting_params
    params.require(:notification_setting).
        permit :stock_notification, :new_review_notification, :comment_notification
  end
end
