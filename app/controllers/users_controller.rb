# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  load_and_authorize_resource

  after_filter :store_location, only: [:show]

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
    current_user.current_auth.share  params[:share][:content]
    render layout: false
  end
end
