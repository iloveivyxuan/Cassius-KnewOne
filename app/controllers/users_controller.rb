# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  load_and_authorize_resource except: [:fuzzy]

  def show
    @reviews = @user.reviews.where(:thing_id.ne => nil).limit(4)
    @fancies = @user.fancies.limit(3)
    @owns = @user.owns.limit(3)
  end

  def fancies
    @fancies = @user.fancies
  end

  def owns
    @owns = @user.owns
  end

  def reviews
    @reviews = @user.reviews.where(:thing_id.ne => nil)
  end

  def things
    @things = @user.things
  end

  def groups

  end

  def activities
    # TODO: NYI
  end

  def share
    current_user.auths.select {|a| params[:providers].include? a.provider}.each do |auth|
      auth.share params[:share][:content], params[:share][:pic]
    end

    render nothing: true
  end

  def follow
    current_user.follow @user

    respond_to do |format|
      format.html { redirect_stored_or user_path(@user) }
      format.js
    end
  end

  def unfollow
    current_user.unfollow @user

    respond_to do |format|
      format.html { redirect_stored_or user_path(@user) }
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
end
