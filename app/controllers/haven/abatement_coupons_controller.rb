module Haven
  class AbatementCouponsController < ApplicationController
    load_and_authorize_resource instance_name: :coupon, class: ::AbatementCoupon, params: :abatement_coupon_params

    def index

    end

    def show

    end

    def new
      @coupon = AbatementCoupon.new
    end

    def create
      @coupon = AbatementCoupon.create abatement_coupon_params
      redirect_to haven_abatement_coupon_path(@coupon)
    end

    def generate_code
      amount = params[:amount].present? ? params[:amount].to_i : 1
      amount.times do
        @coupon.generate_code!
      end
      redirect_to haven_abatement_coupon_path(@coupon)
    end

    private
    def abatement_coupon_params
      params.require(:abatement_coupon).permit!
    end
  end
end
