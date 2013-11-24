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
      redirect_to haven_abatement_coupon_path(@coupon)
    end

    def disable
      @coupon.disable!
      redirect_to haven_abatement_coupon_path(@coupon)
    end
  end
end
