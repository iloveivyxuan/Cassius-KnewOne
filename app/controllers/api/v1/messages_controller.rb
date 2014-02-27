# -*- coding: utf-8 -*-
module Api
  module V1
    class MessagesController < ApiController
      doorkeeper_for :all

      def index
        if params[:scope] == 'unread'
          @messages = current_user.messages.unread.page(params[:page]).per(params[:per_page] || 8)
        else
          @messages = current_user.messages.page(params[:page]).per(params[:per_page] || 8)
        end
      end

      def mark
        current_user.messages.unread.each &:read!
        head :no_content
      end
    end
  end
end
