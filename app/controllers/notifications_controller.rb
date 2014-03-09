# -*- coding: utf-8 -*-
class NotificationsController < ApplicationController
  prepend_before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.page params[:page]
    @unread_count = current_user.notifications.unread.count
  end

  def mark
    current_user.notifications.mark_as_read
    redirect_to notifications_path
  end
end
