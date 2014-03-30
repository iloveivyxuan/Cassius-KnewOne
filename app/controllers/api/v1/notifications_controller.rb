# -*- coding: utf-8 -*-
module Api
  module V1
    class NotificationsController < ApiController
      doorkeeper_for :all

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
        @notifications = @notifications.page(params[:page]).per(params[:per_page] || 24)
      end

      def mark
        current_user.notifications.unread.set read: true
        head :no_content
      end
    end
  end
end
