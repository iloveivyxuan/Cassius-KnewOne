module Haven
  class CouponCodesController < Haven::ApplicationController
    before_action :set_coupon_code

    def destroy
      @coupon_code.destroy

      redirect_to :back
    end

    private

    def set_coupon_code
      @coupon_code = CouponCode.find params[:id]
    end
  end
end
