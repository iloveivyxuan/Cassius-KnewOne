class ProfilesController < ApplicationController
  before_filter :authenticate_user!

  def update
    respond_to do |format|
      if current_user.update_attributes(params[:user])
        format.html { redirect_to root_path, notice: t('devise.registrations.updated') }
        format.json { head :no_content }
      else
        format.html { render "devise/registrations/edit" }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end
end
