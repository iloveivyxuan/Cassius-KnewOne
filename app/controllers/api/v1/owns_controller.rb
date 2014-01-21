module Api
  module V1
    class OwnsController < ApiController
      helper 'api/v1/users'
      doorkeeper_for :all

      def index
        @fancies = current_user.fancies
      end

      def show
      end

      def create
      end

      def destroy
      end
    end
  end
end
