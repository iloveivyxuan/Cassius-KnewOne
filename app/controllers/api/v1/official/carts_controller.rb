module Api
  module V1
    module Official
      class CartsController < OfficialApiController
        doorkeeper_for :all, scopes: [:official]

        def show
          @items = current_user.cart_items
        end
      end
    end
  end
end
