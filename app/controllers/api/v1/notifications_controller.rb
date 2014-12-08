module Api
  module V1
    class NotificationsController < ApiController
      doorkeeper_for :all

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

        @notifications = @notifications.page(params[:page]).per(params[:per_page] || 24)
      end

      def mark
        current_user.set unread_notifications_count: 0
        current_user.notifications.unread.set read: true
        head :no_content
      end
    end
  end
end
