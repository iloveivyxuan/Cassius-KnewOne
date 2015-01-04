module Haven
  class AbatementCouponsController < Haven::ApplicationController
    load_and_authorize_resource instance_name: :coupon, class: ::AbatementCoupon, params: :abatement_coupon_params
    layout 'settings'

    def index

    end

    def show
      @coupon_codes = @coupon.coupon_codes.page(params[:page]).per(params[:per_page] || 20)
    end

    def new
      @coupon = AbatementCoupon.new
    end

    def update
      if @coupon.update abatement_coupon_params
        redirect_to haven_abatement_coupon_path(@coupon)
      else
        render 'show'
      end
    end

    def create
      @coupon = AbatementCoupon.create abatement_coupon_params
      redirect_to haven_abatement_coupon_path(@coupon)
    end

    def generate_code
      amount = params[:amount].present? ? params[:amount].to_i : 1
      amount.times do
        @coupon.generate_code! expires_at: params[:expires_at], admin_note: params[:admin_note], generator_id: current_user.id.to_s
      end
      redirect_to haven_abatement_coupon_path(@coupon)
    end

    def batch_bind
      list = params[:user_list].split("\r\n")
      users = User.or({:email.in => list}, {:name.in => list}, {:id.in => list})
      users.each do |u|
        @coupon.generate_code! user: u, expires_at: params[:expires_at], admin_note: params[:admin_note], generator_id: current_user.id.to_s
      end

      redirect_to haven_abatement_coupon_path(@coupon)
    end

    private
    def abatement_coupon_params
      params.require(:abatement_coupon).permit!
    end
  end
end
