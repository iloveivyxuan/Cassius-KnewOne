module Haven
  class ThingsController < ApplicationController
    load_and_authorize_resource :thing, class: ::Thing
    layout 'settings'

    def edit
    end

    def update
      if @thing.update thing_params
        redirect_to edit_haven_thing_path(@thing)
      else
        render 'edit'
      end
    end

    def index
      @things = case params[:filter]
                  when "can_buy" then
                    Thing.ne(shop: "")
                  else
                    Thing
                end

      @things = case params[:sort_by]
                when 'reviews_count'
                  @things.order_by [:reviews_count, :desc]
                when 'feelings_count'
                  @things.order_by [:feelings_count, :desc]
                when 'priority'
                  @things.order_by [:priority, :desc]
                when 'heat'
                  @things.order_by [:heat, :desc]
                else
                  @things.order_by [:created_at, :desc]
                end

      if params[:from].present?
        @things = @things.where(:created_at.gte => Date.parse(params[:from]))
      end
      if params[:to].present?
        @things = @things.where(:created_at.lt => Date.parse(params[:to]).next_day)
      end

      @things = @things.page params[:page]
    end

    def send_stock_notification
      @thing.notify_fanciers_stock

      redirect_to edit_haven_thing_path(@thing)
    end

    def batch_edit
      @things = case params[:filter]
                when "no_link"
                  Thing.where(shop: "")
                when "no_category"
                  Thing.where(categories: [])
                when "no_price"
                  Thing.where(price: nil)
                when "concept", "kick", "pre_order", "domestic", "abroad", "dsell"
                  Thing.where(stage: params[:filter])
                else
                  Thing.desc(:created_at)
                end

      # order
      @things = case params[:order_by]
                when "priority_asc"
                  Thing.order_by([:priority, :asc])
                when "priority_desc"
                  Thing.order_by([:priority, :desc])
                else
                  @things
                end

      @things = @things.page params[:page]
    end

    def batch_update
      params[:things].each do |t|
        Thing.find(t.delete(:id)).update_attributes! t.permit!
      end

      redirect_back_or batch_edit_haven_things_path
    end

    private

    def thing_params
      params.require(:thing).permit!
    end
  end
end
