# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  load_and_authorize_resource except: [:fuzzy]
  after_action :store_location, except: [:follow, :fuzzy]

  def show
    @reviews = @user.reviews.where(:thing_id.ne => nil)
    @fancies = @user.fancies.limit(3)
    @owns = @user.owns.limit(3)
    @topics = @user.reviews.where(:thing_id.ne => nil).limit(10)
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

  def topics
    @topics = @user.reviews.where(:thing_id.ne => nil)
  end

  def things
    @things = @user.things
  end

  def groups

  end

  def timeline
    # TODO: NYI
  end

  def share
    current_user.auths.select {|a| params[:providers].include? a.provider}.each do |auth|
      auth.share params[:share][:content], params[:share][:pic]
    end

    render nothing: true
  end

  def follow
    current_user.hosts<< @user

    respond_to do |format|
      format.html { redirect_stored_or user_path(@user) }
      format.json { head :no_content }
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
