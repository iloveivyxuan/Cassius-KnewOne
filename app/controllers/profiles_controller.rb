class ProfilesController < ApplicationController
  prepend_before_action :require_signed_in
  skip_before_action :require_not_blocked, only: [:update, :edit]
  layout 'settings'

  def update
    params[:user][:auto_update_from_oauth] = false

    respond_to do |format|
      if current_user.update_without_password(user_params)
        format.html { redirect_to edit_profile_path, flash: {profile: { status: 'success', text: '修改成功。' }} }
        format.json { head :no_content }
      else
        format.html { render "profiles/edit", layout: 'settings' }
        format.json { render json: current_user.errors, status: :unprocessable_entity }
      end
    end
  end

  def edit
  end

  def recommend_users
    @friends = current_user.recommend_users || []

    @recommend_users = User.desc(:recommend_priority, :followers_count).limit(42) - @friends
  end

  def follow_recommends
    scopes = params[:scope].blank? ? %w(weibo recommends) : params[:scope].split(',')

    if scopes.include?('weibo')
      if friends = current_user.recommend_users
        current_user.batch_follow friends
      end
    end

    if scopes.include?('recommends')
      current_user.batch_follow User.desc(:recommend_priority, :followers_count).limit(42)
    end

    redirect_back_or root_path
  end

  def drafts
  end

  private

  def user_params
    params.require(:user).
        permit :avatar, :avatar_cache, :name, :gender, :description, :location, :site, :auto_update_from_oauth, :canopy
  end
end
