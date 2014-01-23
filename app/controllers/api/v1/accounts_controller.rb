module Api
  module V1
    class AccountsController < ApiController
      helper 'api/v1/users'
      doorkeeper_for :all
      before_action :set_user

      def show

      end

      def profile

      end

      def email

      end

      def password

      end
    end
  end
end
