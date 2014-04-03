# -*- coding: utf-8 -*-
class NotificationsController < ApplicationController
  prepend_before_action :authenticate_user!
  after_action :mark_read, only: [:index]

  def index
    @notifications = current_user.notifications

    case params[:scope]
      when 'unread'
        @notifications = @notifications.unread
      when 'read'
        @notifications = @notifications.marked_as_read
    end

    if params[:types]
      types = params[:types].split(',')
      @notifications = @notifications.by_types(types) if types.any?
    end

    @notifications = @notifications.page params[:page]
    @unread_count = current_user.notifications.unread.count

    if request.xhr?
      render 'notifications/index_xhr', layout: false
    else
      render 'notifications/index'
    end
  end

  def mark
    current_user.notifications.mark_as_read

    respond_to do |format|
      format.html { redirect_to notifications_path }
      format.json { head :no_content }
    end
  end

  private

  def mark_read
    @notifications.set read: true
  end
end
