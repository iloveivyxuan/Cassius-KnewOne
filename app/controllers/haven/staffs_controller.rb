# -*- coding: utf-8 -*-
module Haven
  class StaffsController < ApplicationController
    layout 'settings'
    before_action :authenticate_admin

    def index
      @users ||= ::User
      if params[:name].present?
        @users = @users.where(name: /^#{Regexp.escape(params[:name])}/i)
      elsif params[:filter]
        if params[:filter].include? 'staff'
          @users = @users.staff
        end
        if params[:filter].include? 'admin'
          @users = @users.admin
        end
        if params[:filter].include? 'editor'
          @users = @users.editor
        end
        if params[:filter].include? 'sale'
          @users = @users.sale
        end
      else
      @users = @users.order_by([:created_at, :desc],
                               [:things_count, :desc],
                               [:reviews_count, :desc],
                               [:orders_count, :desc])
      end
      @users = @users.page params[:page]
      respond_to do |format|
        format.html
      end
    end

    def show
      @user = User.find(params[:id])
    end

    def update
      user = User.find(params[:id])
      params[:user][:role] = params[:user][:role].first

      user.update(user_params)

      redirect_back_or haven_staffs_path
    end

    private

    def user_params
      params.require(:user).permit!
    end

    def authenticate_admin
      raise ActionController::RoutingError.new('Not Found') unless current_user.try(:role) == "admin"
    end

  end
end
