module Haven
  class ThingsController < ApplicationController
    load_and_authorize_resource :thing, class: ::Thing
    layout 'settings'

    def edit
    end

    def update
      logger.tagged("Haven-Thing-Update") do
        logger.info current_user.name
        logger.info @thing.id
        logger.info thing_params
      end
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
      @things ||= ::Thing
      if params[:filter]
        @things = @things.where(shop: "") if params[:filter].include? "no_link"
        @things = @things.where(categories: []) if params[:filter].include? "no_category"
        @things = @things.where(price: nil) if params[:filter].include? "no_price"
        @things = @things.where(stage: "concept") if params[:filter].include? "concept"
        @things = @things.where(stage: "kick") if params[:filter].include? "kick"
        @things = @things.where(stage: "pre_order") if params[:filter].include? "pre_order"
        @things = @things.where(stage: "domestic") if params[:filter].include? "domestic"
        @things = @things.where(stage: "abroad") if params[:filter].include? "abroad"
        @things = @things.where(stage: "desell") if params[:filter].include? "dsell"
        @things = @things.order_by([:feelings_count, :desc]) if params[:filter].include? "feelings_count"
        @things = @things.order_by([:reviews_count, :desc]) if params[:filter].include? "reviews_count"
        @things = @things.order_by([:heat, :desc]) if params[:filter].include? "heat"
        @things = @things.order_by([:priority, :asc]) if params[:filter].include? "priority_asc"
        @things = @things.order_by([:priority, :desc]) if params[:filter].include? "priority_desc"
      else
        @things = @things.desc(:created_at)
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
