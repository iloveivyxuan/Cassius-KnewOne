# -*- coding: utf-8 -*-
class NotificationsController < ApplicationController
  prepend_before_action :authenticate_user!
  after_action :mark_no_context_read, only: [:index]
  after_action :cleanup_orphan, only: [:index]

  def index
    @notifications = current_user.notifications
    if params[:scope] == 'unread'
      @notifications
    end
    case params[:scope]
      when 'unread'
        @notifications = @notifications.unread
      when 'read'
        @notifications = @notifications.marked_as_read
    end
    @notifications = @notifications.page params[:page]
    @unread_count = current_user.notifications.unread.count

    respond_to do |format|
      format.html
      format.json
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

  def mark_no_context_read
    Notification.mark_as_read_by_context(current_user, nil)
  end

  def cleanup_orphan
    Notification.batch_mark_as_read @notifications.select(&:orphan?).map(&:id)
  end
end
