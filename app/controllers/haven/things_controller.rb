module Haven
  class ThingsController < Haven::ApplicationController
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
        @things = @things.any_in(:tag_ids => [nil, []]) if params[:filter].include? "no_tag"
        @things = @things.where(official_site: "") if params[:filter].include? "no_official"
        @things = @things.where(brand: nil) if params[:filter].include? "no_brand"

        Thing::STAGES.keys.each do |stage|
          @things = @things.where(stage: stage) if params[:filter].include? stage.to_s
        end

        %w(feelings_count reviews_count heat priority).each do |sort_key|
          @things = @things.order_by([sort_key.to_sym, :desc]) if params[:filter].include? sort_key
        end

        @things = @things.order_by([:priority, :asc]) if params[:filter].include? "priority_asc"
        @things = @things.order_by([:created_at, :desc]) if params[:filter].include? "created_at_desc"
        @things = @things.order_by([:created_at, :asc]) if params[:filter].include? "created_at_asc"
      end
      @things = @things.in(categories: params[:categories]) if params[:categories]
      @things = @things.where(shop: Regexp.new(params[:shop])) if params[:shop]
      if params[:tag]
        tag = Tag.where(name: params[:tag]).first
        @things = @things.any_in(:tag_ids => tag) if tag
      end
      if params[:title]
        q = (params[:title] || '')
        q.gsub!(/[^\u4e00-\u9fa5a-zA-Z0-9[:blank:].-_]+/, '')
        q = Regexp.escape(q)
        @things = @things.published.or({slug: /#{q}/i}, {title: /#{q}/i}, {subtitle: /#{q}/i})
      end
      if params[:brand]
        brand = Brand.where(name: Regexp.new(params[:brand], Regexp::IGNORECASE)).first
        @things = @things.where(brand: brand) if brand
      end
      if params[:official]
        @things = @things.where(official_site: Regexp.new(params[:official], Regexp::IGNORECASE))
      end
      if params[:price_unit]
        @things = @things.where(price_unit: params[:price_unit])
      end
      unless params[:filter] || params[:categories]
        @things = @things.desc(:created_at)
      end
      @things = @things.page params[:page]
    end

    def batch_update
      if thing_params = params[:things].first
        @thing = Thing.find(thing_params.delete :id)
        @thing.assign_attributes thing_params.permit!
        @changes = @thing.changes
        if @thing.save
          render js: { status: true, changes: @changes }.to_json
        else
          render js: @thing.errors.full_messages
        end
      end
    end

    # notify user that his thing has been into hits
    def send_hits_message
      thing = Thing.find params[:thing]
      user = thing.author
      knewone = User.where(id: '511114fa7373c2e3180000b4').first

      return unless user && knewone && thing
      content = "#{user.name}，我们很高兴地通知您，您分享的 <a href='#{thing_url(thing)}'>#{thing.title}</a> 已经通过审核，被放入<a href='#{latest_path}'>「最新推荐」</a>啦！谢谢您的分享~"
      knewone.send_private_message_to(user, content)
      redirect_to :back, flash: { msg: "已成功向用户发送私信" }
    end

    private

    def thing_params
      params.require(:thing).permit!
    end
  end
end
