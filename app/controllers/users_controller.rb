# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  prepend_before_action :require_signed_in, only: [:share, :follow, :unfollow]
  before_action :set_user, except: [:share, :fuzzy]
  after_action :store_location, except: [:follow, :unfollow, :share, :fuzzy]

  def show
    @reviews = @user.reviews.where(:thing_id.ne => nil).limit(4)
    @fancies = @user.fancies.limit(3)
    @owns = @user.owns.limit(3)
    @activities = @user.activities.visible.limit(10)
  end

  def fancies
    @fancies = @user.fancies_sorted_by_ids(params[:page], 24)
  end

  def owns
    @owns = @user.owns_sorted_by_ids(params[:page], 24)
  end

  def reviews
    @reviews = @user.reviews.where(:thing_id.ne => nil).page(params[:page]).per(24)
  end

  def things
    @things = @user.things.page(params[:page]).per(24)
  end

  def groups
    @groups = Group.find_by_user(@user).page(params[:page]).per(24)
  end

  def topics
    @topics = @user.topics.page(params[:page]).per(20)
  end

  def activities
    @activities = @user.activities.visible.page(params[:page]).per(24)
  end

  def followings
    @followings = @user.followings.page(params[:page]).per(24)
  end

  def followers
    @followers = @user.followers.page(params[:page]).per(24)
  end

  def share
    current_user.auths.select {|a| params[:providers].include? a.provider}.each do |auth|
      auth.share params[:share][:content], params[:share][:pic]
    end

    render nothing: true
  end

  def follow
    current_user.follow @user
    current_user.log_activity :follow_user, @user, check_recent: true

    respond_to do |format|
      format.html { redirect_stored_or user_url(@user) }
      format.js
    end
  end

  def unfollow
    current_user.unfollow @user

    respond_to do |format|
      format.html { redirect_stored_or user_url(@user) }
      format.js
    end
  end

  def fuzzy
    @users = User.find_by_fuzzy_name(params[:query])
    respond_to do |format|
      format.json do
        @users = @users.limit(20)
      end
    end
  end

  private

  def set_user
    if request.subdomain.present?
      @user = User.find_by personal_domain: request.subdomain
    else
      @user = User.find(params[:id] || params[:user_id])
    end
  end
end
