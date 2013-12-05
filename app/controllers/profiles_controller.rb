class ProfilesController < ApplicationController
  before_filter :authenticate_user!

  def update
    respond_to do |format|
      if current_user.update(user_params)
        format.html { redirect_to root_path, notice: t('devise.registrations.updated') }
        format.json { head :no_content }
      else
        format.html { render "devise/registrations/edit" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def user_params
    params.require(:user).permit :avatar, :avatar_cache, :name, :nickname, :description, :location
  end
end
