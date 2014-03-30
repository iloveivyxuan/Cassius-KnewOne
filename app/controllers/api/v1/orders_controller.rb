module Api
  module V1
    class OrdersController < ApiController
      doorkeeper_for :all, except: [:tenpay_callback, :alipay_callback], scopes: [:official]

      def show
        @order = current_user.orders.find(params[:id])
      end

      def index
        @orders = current_user.orders
        @orders = @orders.where(state: params[:state]) if params[:state]
        @orders = @orders.page(params[:page]).per(params[:per_page] || 8)
      end

      def create
        @order = Order.build_order(current_user, order_params)

        if @order.save
          render action: 'show', status: :created, location: [:api, :v1, :account, @order]
        else
          render json: @order.errors, status: :unprocessable_entity
        end
      end

      def cancel
        current_user.orders.find(params[:id]).cancel!
        head :no_content
      end

      def tenpay_callback

      end

      def alipay_callback

      end

      private

      def order_params
        params.require(:order).
            permit(:note, :address_id, :auto_owning, :coupon_code_id, :use_balance, :use_sf)
      end
    end
  end
end
