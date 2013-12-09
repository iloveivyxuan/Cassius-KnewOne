class ProfilesController < ApplicationController
  prepend_before_filter :authenticate_user!
  layout 'settings'

  def update
    respond_to do |format|
      if current_user.update(user_params)
        format.html { redirect_to edit_profile_path, notice: t('devise.registrations.updated') }
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

  def user_params
    params.require(:user).permit :avatar, :avatar_cache, :name, :nickname, :description, :location
  end
end
