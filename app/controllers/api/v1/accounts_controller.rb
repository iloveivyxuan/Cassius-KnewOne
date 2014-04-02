module Api
  module V1
    class AccountsController < ApiController
      doorkeeper_for :all

      def show
      end
    end
  end
end
