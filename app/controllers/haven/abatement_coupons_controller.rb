module Haven
  class AbatementCouponsController < ApplicationController
    load_and_authorize_resource instance_name: :coupon, class: ::AbatementCoupon

    def index

    end

    def show

    end

    def new
      @coupon = AbatementCoupon.new
    end

    def create
      @coupon = AbatementCoupon.create params[:abatement_coupon]
      # redirect_to haven_abatement_coupon_path(@coupon)
      redirect_to haven_abatement_coupons_path
    end

    def generate_code
      amount = params[:amount].present? ? params[:amount].to_i : 1
      amount.times do
        @coupon.generate_code!
      end
      redirect_to haven_abatement_coupon_path(@coupon)
    end
  end
end
