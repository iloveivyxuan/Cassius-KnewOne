module Haven
  class PrizesController < Haven::ApplicationController
    layout 'settings'
    before_action :set_prize, only: [:edit, :update, :destroy]

    def index
      @prizes = Prize.all.desc(:since).page(params[:page])

      @share_things = Prize.share_things
      @share_reviews = Prize.share_reviews
      @share_lists = Prize.share_lists

      if params[:find_by]
        since = Date.parse params[:start_date]
        due = Date.parse(params[:end_date]).next_day

        klass = case params[:find_by]
                when "most_things", "most_fancied_things"
                  Thing.between(approved_at: since..due)
                when "most_reviews", "most_fancied_reviews"
                  Review.between(created_at: since..due)
                when "most_thing_lists", "most_fancied_thing_lists"
                  ThingList.between(created_at: since..due)
                end

        @result = if ["most_things", "most_reviews", "most_thing_lists"].include? params[:find_by]
                    User.in(id: klass.distinct(:author_id))
                      .map { |user| [user, klass.where(author_id: user.id).count] }
                      .sort_by { |k, v| v }.reverse
                  else
                    User.in(id: klass.distinct(:author_id))
                      .map { |user| [user, klass.where(author_id: user.id).map { |k| k.try(:fanciers_count) || k.try(:lovers_count) }.reduce(&:+)] }
                      .sort_by { |k, v| v }.reverse
                  end
      end

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
