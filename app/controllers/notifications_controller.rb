# -*- coding: utf-8 -*-
class NotificationsController < ApplicationController
  prepend_before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.page params[:page]
    @unread_count = current_user.messages.unread.count
  end

  def mark
    current_user.messages.unread.each {|message| message.read!}
    redirect_to messages_path
  end
end
