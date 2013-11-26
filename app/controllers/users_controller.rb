# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  load_and_authorize_resource only: [:show, :index]

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
    current_user.auths.select {|a| params[:providers].include? a.provider}.each do |auth|
      auth.share params[:share][:content], params[:share][:pic]
    end

    render nothing: true
  end

  def bind
    if current_user.update_attributes params[:user]
      current_user.resend_confirmation_instructions
      redirect_to root_path, :notice => '已向您发送验证邮件！'
    else
      render 'binding'
    end
  end

  def binding

  end
end
