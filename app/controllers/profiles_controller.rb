class ProfilesController < ApplicationController
  prepend_before_action :require_signed_in
  layout 'settings'

  def update
    params[:user][:auto_update_from_oauth] = false

    respond_to do |format|
      if current_user.update_without_password(user_params)
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

  def user_params
    params.require(:user).
        permit :avatar, :avatar_cache, :name, :description, :location, :site, :auto_update_from_oauth
  end
end
