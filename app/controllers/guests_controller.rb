# -*- coding: utf-8 -*-
class GuestsController < ApplicationController
  load_and_authorize_resource

  def index
    @guests = Guest.page params[:page]
  end

  def create
    10.times { Guest.create }
    redirect_to guests_path
  end

  def destroy
    @guest.destroy
    redirect_to guests_path
  end

  def activate
    @guest = Guest.where(token: params[:token]).first
    if @guest and @guest.user.blank?
      if current_user.blank?
        render "activate_login"
        store_location
      else
        if Guest.where(user_id: current_user.id).blank?
          @guest.user = current_user
          @guest.save
        end
        flash[:activate] = true
        redirect_to root_path
      end
    else
      render "activate_fail"
    end
  end

  def limits
    redirect_to root_path unless current_user and current_user.is_guest?
    @things = Thing.where(is_limit: true)
  end

end
