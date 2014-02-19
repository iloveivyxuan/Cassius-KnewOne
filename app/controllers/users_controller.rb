# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  load_and_authorize_resource only: [:show, :index]

  def show
    @things = @user.things
    @reviews = @user.reviews
    @fancies = @user.fancies
    @owns = @user.owns
  end

  def index
    @users = User.desc(:created_at).page params[:page]
  end

  def share
    current_user.auths.select {|a| params[:providers].include? a.provider}.each do |auth|
      auth.share params[:share][:content], params[:share][:pic]
    end

    render nothing: true
  end

  def fuzzy
    @users = User.find_by_fuzzy_name(params[:keyword])
    respond_to do |format|
      format.html do
        @users = @users.page(params[:page])
        render 'index'
      end
      format.json do
        @users = @users.limit(10)
      end
    end
  end
end
