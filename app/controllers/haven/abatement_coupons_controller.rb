module Haven
  class AbatementCouponsController < ApplicationController
    load_and_authorize_resource instance_name: :coupon, class: ::AbatementCoupon

    def index

    end

    def show

    end

    def new
      @coupon = AbatementCoupon.generate
    end

    def create
      @coupon = AbatementCoupon.generate! params[:abatement_coupon]
      # redirect_to haven_abatement_coupon_path(@coupon)
      redirect_to haven_abatement_coupons_path
    end

    def disable
      @coupon.status = :disabled
      @coupon.save

      redirect_to haven_abatement_coupons_path
    end
  end
end
