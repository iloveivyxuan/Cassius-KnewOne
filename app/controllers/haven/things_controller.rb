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

    def part_time_list name
      case name
      when 'linlidan'
        %w(5457108131302d300a990000 541db6a931302d0ca9690700 533ff45d31302d5426a80300 54295ec831302d6c79440000 5382fc1731302d2932350000 5429765731302d0dbd600000)
      when 'zhongkai'
        %w(5444cab931302d282c0e0000 544903e131302d77a7180000 546480a331302d4131220000 54201d8131302d31d2df0000 535d1d0a31302d57d3d50500)
      when 'yanjingwei'
        %w(540448d131302d275b110000 5459ae2b31302d572c240000 5421205a31302d741b360000 513de38f7373c292ed000008 53e4896131302d7ac07f0200 53d1bc2031302d0bb5270100)
      when 'xiaoqiu'
        %w(542903a531302d1e6e000000 54811bc031302d4e6bb80000 5381ffb231302d1a768b0000 5497a52031302d0f421b0000 5321d08631302d2f79520000 54ab7e9931302d7bbd0a0100)
      else
        whole_list = []
        %w(linlidan zhongkai yanjingwei xiaoqiu).each do |name|
          whole_list += part_time_list(name)
        end
        whole_list
      end
    end

    def batch_edit
      @things ||= ::Thing
      case params[:team]
      when 'linlidan'
        @things = @things.in('author_id' => part_time_list('linlidan'))
      when 'zhongkai'
        @things = @things.in('author_id' => part_time_list('zhongkai'))
      when 'yanjingwei'
        @things = @things.in('author_id' => part_time_list('yanjingwei'))
      when 'xiaoqiu'
        @things = @things.in('author_id' => part_time_list('xiaoqiu'))
      when 'no_team'
        @things = @things.nin(author_id: part_time_list('no_team'))
      end
      if params[:filter]
        @things = @things.where(shop: "") if params[:filter].include? "no_link"
        @things = @things.where(categories: []) if params[:filter].include? "no_category"
        @things = @things.where(price: nil) if params[:filter].include? "no_price"
        @things = @things.any_in(:tag_ids => [nil, []]) if params[:filter].include? "no_tag"
        @things = @things.where(official_site: "") if params[:filter].include? "no_official"
        @things = @things.no_brand if params[:filter].include? "no_brand"

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
      if params[:category]
        category = Category.where(name: params[:category]).first
        @things = @things.in(category_ids: category.id) if category
      end
      @things = @things.where(shop: Regexp.new(params[:shop])) if params[:shop]
      if params[:title]
        q = (params[:title] || '')
        q.gsub!(/[^\u4e00-\u9fa5a-zA-Z0-9[:blank:].-_]+/, '')
        q = Regexp.escape(q)
        @things = @things.published.or({slug: /#{q}/i}, {title: /#{q}/i}, {subtitle: /#{q}/i})
      end
      if params[:brand]
        brand = Brand.where(en_name: /#{params[:brand]}/i).first
        brand ||= Brand.where(zh_name: /#{params[:brand]}/i).first
        @things = @things.by_brand(brand) if brand
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
      @things = @things.includes(:brand, :author).page params[:page]
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

    def approved_status
      from = begin Date.parse params[:from] rescue nil end
      to = begin Date.parse params[:to] rescue nil end

      unless from && to
        head :no_content
        return
      end

      @things = Thing.gte(created_at: from).lte(created_at: to.next_day)
      tags = @things.map(&:tags).flatten
      result = {}
      tags.each { |tag| result[tag.name] = tags.count(tag) }
      @sorted = result.sort_by { |k, v| v }.reverse
      @values = @sorted.map(&:last).uniq
      sites = @things.map(&:official_site).map do |site|
        begin
          URI.parse(URI::escape(site)).host unless site.blank?
        rescue
          nil
        end
      end.compact
      result = {}
      sites.each { |site| result[site] = sites.count(site) }
      @sorted_sites = result.sort_by { |k, v| v }.reverse
      brands = @things.map(&:brand).flatten.compact
      result = {}
      brands.each { |brand| result[brand] = brands.count(brand) }
      @sorted_brands = result.sort_by { |k, v| v }.reverse

      if params[:new_sources]
        @sources = {}
        sources = params[:new_sources].split
        sources.each do |shop|
          @sources[shop] = @things.where(shop: /#{shop}/).size
        end
      end

      if params[:new_brands]
        @brands = {}
        brands = params[:new_brands].split
        brands.each do |b|
          b.downcase!
          @brands[b] = @things.map(&:brand).compact.map(&:brand_text).map(&:downcase).count(b)
        end
      end
    end

    private

    def thing_params
      params.require(:thing).permit!
    end
  end
end
