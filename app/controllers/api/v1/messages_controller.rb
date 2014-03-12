# -*- coding: utf-8 -*-
module Api
  module V1
    class MessagesController < ApiController
      doorkeeper_for :all

      def index
        if params[:scope] == 'unread'
          @messages = current_user.notifications.by_type(:comment).unread.page(params[:page]).per(params[:per_page] || 8)
        else
          @messages = current_user.notifications.by_type(:comment).page(params[:page]).per(params[:per_page] || 8)
        end
      end

      def mark
        current_user.notifications.by_type(:comment).unread.set read: true
        head :no_content
      end
    end
  end
end
