module Haven
  class PrizesController < Haven::ApplicationController
    layout 'settings'
    before_action :set_prize, only: [:edit, :update, :destroy]

    def index
      @prizes = Prize.all.desc(:since)

      @share_things = Prize.share_things
      @share_reviews = Prize.share_reviews
      @share_lists = Prize.share_lists
    end

    def new
      @prize ||= Prize.new
    end

    def edit
    end

    def create
      coupon = Coupon.where(id: params[:prize][:coupon_id]).first
      if coupon
        @prize = Prize.new prize_params
        @prize.save
        redirect_to haven_prizes_path
      else
        redirect_to :back, flash: { error: "优惠券不存在" }
      end
    end

    def update
      @prize.assign_attributes prize_params
      if @prize.save
        redirect_to haven_prizes_path
      else
        redirect_to :back, flash: { error: @prize.errors.full_messages }
      end
    end

    def destroy
      @prize.delete
      redirect_to :back
    end

    def santa
      Prize.where(coupon_code_id: nil).each do |p|
        if (p.name == "产品") || p.reference_id.present?
          p.surprise!
        end
      end
      redirect_to haven_prizes_path
    end

    private

    def set_prize
      @prize = Prize.find params[:id]
    end

    def prize_params
      params.require(:prize).permit!
    end
  end
end
