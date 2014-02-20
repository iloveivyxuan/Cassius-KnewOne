module Api
  module V1
    class CouponsController < ApiController
      doorkeeper_for :all

      def index
        @coupons = current_user.coupon_codes
        if params[:scope].present? && params[:scope] == 'instant'
          order = Order.build_order(current_user)
          @coupons = @coupons.select {|c| c.test?(order)}
        end
      end

      def update
        coupon = CouponCode.find_unused_by_code params[:id]
        return head :not_found unless coupon
        return head :unprocessable_entity unless coupon.bind_user! current_user
        head :no_content
      end
    end
  end
end
