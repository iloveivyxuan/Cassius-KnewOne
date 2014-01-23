module Api
  module V1
    class CartsController < ApiController
      doorkeeper_for :all

      def show
        @items = current_user.cart_items
      end
    end
  end
end
