module Api
  module V1
    class CartItemsController < ApiController
      doorkeeper_for :all

      def show
        @item = current_user.cart_items.find(params[:id])
      end

      def index
        @items = current_user.cart_items
      end

      def create
        current_user.add_to_cart params[:cart_item]
        head :no_content
      end

      def update
        item = current_user.cart_items.find(params[:id])
        if item.update update_item_params
          head :no_content
        else
          render json: item.errors, status: :unprocessable_entity
        end
      end

      def destroy
        current_user.cart_items.delete current_user.cart_items.find(params[:id])
        head :no_content
      end

      private

      def update_item_params
        params.require(:item).permit(:quantity)
      end

      def create_item_params
        params.require(:item).permit(:thing_id, :kind_id, :quantity)
      end
    end
  end
end
