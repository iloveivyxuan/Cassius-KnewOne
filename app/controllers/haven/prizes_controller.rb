module Haven
  class PrizesController < Haven::ApplicationController
    layout 'settings'

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
      @prize = Prize.find params[:id]
    end

    def create
      coupon = Coupon.where(id: params[:prize][:coupon_id]).first
      if coupon
        @prize = Prize.new(params.require(:prize).permit!)
        @prize.save
        redirect_to haven_prizes_path
      else
        redirect_to :back, flash: { error: "优惠券不存在" }
      end
    end

    def destroy
      @prize = Prize.find params[:id]
      @prize.delete
      redirect_to :back
    end

    def santa
      Prize.where(coupon_code_id: nil).each do |p|
        p.surprise!
      end
      redirect_to haven_prizes_path
    end
  end
end
