module Api
  module V1
    module Official
      class OrdersController < OfficialApiController
        before_action :have_items_in_cart, only: [:new, :create]

        def show
          @order = current_user.orders.find(params[:id])
        end

        def index
          @orders = current_user.orders
          @orders = @orders.where(state: params[:state]) if params[:state]
          @orders = @orders.page(params[:page]).per(params[:per_page] || 8)
        end

        def new
          @order = Order.build_order(current_user, (params.has_key?(:order) ? order_params : nil))
          @addresses = current_user.addresses
          @coupons = current_user.coupon_codes.select {|c| c.test?(@order)}
        end

        def create
          @order = Order.build_order(current_user, order_params)

          if @order.save
            render action: 'show', status: :created, location: [:api, :v1, @order]
          else
            render json: @order.errors, status: :unprocessable_entity
          end
        end

        def cancel
          current_user.orders.find(params[:id]).cancel!
          head :no_content
        end

        def alipay
          render text: generate_alipay_info(current_user.orders.find(params[:id]))
        end

        private

        def order_params
          params.require(:order).
              permit(:note, :address_id, :auto_owning, :coupon_code_id, :use_balance, :use_sf)
        end

        def body_text(order, length = 16)
          order.order_items.map { |i| "#{i.name}x#{i.quantity}, " }.reduce(&:+)[0..(length-1)]
        end

        def generate_alipay_info(order, options = {})
          options = {
              :out_trade_no => order.order_no,
              :subject => "KnewOne购物订单: #{order.order_no}",
              :body => body_text(order, 500),
              :total_fee => order.should_pay_price,
              :notify_url => alipay_notify_order_url(order)
          }.merge(options)

          Alipay::MobileService.sdk_pay_order_info(options)
        end

        protected

        def have_items_in_cart
          if current_user.cart_items.select { |item| item.legal? && item.has_enough_stock? }.empty?
            render_error :no_item_in_cart, 'Cart is empty!'
          end
        end
      end
    end
  end
end
