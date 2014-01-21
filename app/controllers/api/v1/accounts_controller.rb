module Api
  module V1
    class AccountsController < ApiController
      helper 'api/v1/users'
      doorkeeper_for :all
      before_action :set_user

      def show

      end

      def update

      end

      private

      def set_user
        @user = current_user
      end
    end
  end
end
