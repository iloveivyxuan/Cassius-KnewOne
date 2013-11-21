class ProfilesController < ApplicationController
  prepend_before_filter :authenticate_user!
  layout 'settings'

  def update
    respond_to do |format|
      if current_user.update_attributes(params[:user])
        format.html { redirect_to edit_settings_profile_path, notice: t('devise.registrations.updated') }
        format.json { head :no_content }
      else
        format.html { render "profiles/edit" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit

  end
end
