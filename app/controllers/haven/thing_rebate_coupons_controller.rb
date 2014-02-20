module Haven
  class ThingRebateCouponsController < ApplicationController
    load_and_authorize_resource instance_name: :coupon, class: ::ThingRebateCoupon, params: :thing_rebate_coupon_params
    layout 'settings'

    def index

    end

    def show

    end

    def new
      @coupon = ThingRebateCoupon.new
    end

    def update
      if @coupon.update thing_rebate_coupon_params
        redirect_to haven_thing_rebate_coupon_path(@coupon)
      else
        render 'show'
      end
    end

    def create
      @coupon = ThingRebateCoupon.create thing_rebate_coupon_params
      redirect_to haven_thing_rebate_coupon_path(@coupon)
    end

    def generate_code
      amount = params[:amount].present? ? params[:amount].to_i : 1
      amount.times do
        @coupon.generate_code! expires_at: params[:expires_at], admin_note: params[:admin_note]
      end
      redirect_to haven_thing_rebate_coupon_path(@coupon)
    end

    def batch_bind
      list = params[:user_list].split("\r\n")
      users = User.or({:email.in => list}, {:name.in => list}, {:id.in => list})
      users.each do |u|
        @coupon.generate_code! user: u, expires_at: params[:expires_at], admin_note: params[:admin_note]
      end

      redirect_to haven_thing_rebate_coupon_path(@coupon)
    end

    private
    def thing_rebate_coupon_params
      params.require(:thing_rebate_coupon).permit!
    end
  end
end
