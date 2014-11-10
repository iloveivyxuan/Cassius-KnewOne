class ThingsController < ApplicationController
  include MarkReadable
  include DestroyDraft

  load_and_authorize_resource
  before_action :set_categories, only: [:index]
  after_action :allow_iframe_load, only: [:show]
  after_action :store_location, only: [:comments, :show]
  before_action :delete_links, only: [:destroy]

  def index
    @things ||= ::Thing.published

    if params[:category].present? and params[:category] != 'all'
      @category = Category.find(params[:category])
      @things = @things.by_category(@category).published
    end
    if params[:tag].present?
      @tag = Tag.where(slugs: params[:tag].to_s).first
      @things = @things.by_tag(@tag).published if @tag
    end
    if params[:brand].present?
      @brand = Brand.where(id: params[:brand].to_s).first
      @things = @things.by_brand(@brand).published if @brand
    end

    if params[:sort_by] == 'fanciers_count'
      @things = @things.desc(:fanciers_count)
    else
      @things = @things.desc(:created_at)
    end

    @things = @things.page(params[:page]).per((params[:per] || 24).to_i)

    respond_to do |format|
      format.html do
        if request.xhr?
          if @things.any?
            render partial: 'home/hot_thing', collection: @things, as: :hot_thing, locals: {img_lazy: false, size: :normal}
          else
            head :no_content
          end
        else
          render
        end
      end
      format.atom
      format.json
    end
  end

  def shop
    params[:order_by] ||= "new"

    @things ||= ::Thing
    if params[:categories] && params[:categories] != "all"
      c = Category.any_in(:slugs => params[:categories]).first
      @things = @things.any_in(categories: c.name) if c
    end

    if (params[:price_l] || params[:price_h]) && params[:price_l] != "all"
      params[:price_h] = Float::INFINITY if params[:price_h] == "Infinity"
      @things = @things.price_between(params[:price_l], params[:price_h])
    end

    @sort = case params[:order_by]
            when 'recommended' then {priority: :desc}
            when 'hits' then {fanciers_count: :desc}
            when 'new' then {created_at: :desc}
            when 'price_h_l' then {price: :desc}
            when 'price_l_h' then {price: :asc}
            else {priority: :desc}
            end

    @things = @things.published.self_run.order_by(@sort).page(params[:page]).per(24)

    if request.xhr?
      if @things.any?
        render partial: 'shop_thing', collection: @things, as: :thing
      else
        head :no_content
      end
    end
  end

  def random
    @things = Thing.rand_records (params[:per] || 24).to_i

    respond_to do |format|
      format.html {}
      format.js
      format.json { render 'things/index' }
    end
  end

  def new
    @thing = Thing.new
  end

  def create
    @thing = Thing.new thing_params.merge(author: current_user)
    if @thing.save
      @thing.fancy current_user
      current_user.log_activity :new_thing, @thing

      redirect_to @thing, flash: {provider_sync: params[:provider_sync]}
    else
      render 'new'
    end
  end

  def show
    mark_read @thing

    respond_to do |format|
      format.html { render layout: 'thing' }
      format.json
    end
  end

  def edit
    @photos = @thing.photos.map(&:to_jq_upload)
    render 'new'
  end

  def update
    if @thing.update thing_params
      redirect_to @thing
    else
      render 'new'
    end
  end

  def destroy
    if @thing.safe_destroy?
      @thing.destroy
      current_user.log_activity :delete_thing, @thing, visible: false
      redirect_to root_path
    else
      redirect_to @thing
    end
  end

  def fancy
    if @thing.fancied? current_user
      @thing.unfancy current_user
    else
      @thing.fancy current_user
      current_user.log_activity :fancy_thing, @thing, check_recent: true
    end

    respond_to do |format|
      format.html { redirect_to @thing }
      format.js { head :no_content }
    end
  end

  def own
    if @thing.owned? current_user
      @thing.unown current_user
    else
      @thing.own current_user
      current_user.log_activity :own_thing, @thing, check_recent: true
    end

    respond_to do |format|
      format.html { redirect_to @thing }
      format.js
    end
  end

  def buy
    respond_to do |format|
      format.html { redirect_to @thing.shop }
      format.json { render json: {type: 'taobao', id: '25312892353'} } #fake
    end
  end

  def related
    @things = @thing.related_things
  end

  ACTIVITY_TYPES = ['fancy_thing', 'own_thing', 'add_to_list']
  def activities
    @activities = Activity.visible.by_reference(@thing)

    if ACTIVITY_TYPES.include?(params[:type])
      @activities = @activities.by_types(params[:type])
    else
      @activities = @activities.by_types(*ACTIVITY_TYPES)
    end

    @activities = @activities.page(params[:page]).per(params[:per] || 24)

    respond_to do |format|
      format.html do
        if request.xhr?
          render partial: 'activity', collection: @activities
        else
          render layout: 'thing'
        end
      end
    end
  end

  def extract_url
    return head :not_accepted if params[:url].blank?

    @result = PageExtractor.extract(params[:url])

    if @result
      @result[:title] ||= "请在这里输入产品名称"
      @thing = Thing.new official_site: @result[:url],
      title: @result[:title],
      content: @result[:content]
      title_regexp = /#{Regexp.escape(@result[:title])}/i
      @similar = Thing.published.or({slug: title_regexp},
                                    {title: title_regexp},
                                    {subtitle: title_regexp},
                                    {official_site: params[:url]}
                                    ).desc(:fanciers_count).first
    end

    respond_to do |format|
      format.js
    end
  end

  def create_by_extractor
    return render 'things/create_by_extractor_without_photos' if params[:images].nil? || params[:images].empty?

    photos = params[:images].map do |i|
      i.sub!(%r{^//}, 'http://')
      i.sub!(/!\w+$/, '')
      Photo.create! remote_image_url: i, user: current_user
    end

    @thing = Thing.new thing_params.merge(author: current_user)
    @thing.content = @thing.content.gsub("\r", '').split("\n").compact.map { |l| "<p>#{l}</p>" }.join
    @thing.photo_ids.concat photos.map(&:id)

    if @flag = @thing.save
      @thing.fancy current_user
      current_user.log_activity :new_thing, @thing
    end

    respond_to do |format|
      format.js
    end
  end

  def coupon
    thing = Thing.find(params[:id])
    if thing.id.to_s == "510689ef7373c2f82b000003" # dyson-air-multiplier
      @rebate_coupon = ThingRebateCoupon.find_or_create_by(
                                                           name: "Dyson Air Multiplier 200 元优惠券",
                                                           thing_id: thing.id.to_s,
                                                           price: 200.0)
      coupon_code = @rebate_coupon.generate_code!(
                                                  user: current_user,
                                                  expires_at: 3.months.since.to_date,
                                                  admin_note: "通过领取 Dyson Air Multiplier 优惠券获得",
                                                  generator_id: current_user.id.to_s)
    end
    redirect_to :back
  end

  def delete_links
    thing = Thing.find(params[:id])
    unless thing.links.blank?
      link = thing.links
      link.delete(thing.id.to_s)
      link = [] if link.size < 2
      thing.links.each { |l| Thing.find(l).update_attributes(links: link) }
    end
  end

  private

  def thing_params
    params.require(:thing)
      .permit(:title, :subtitle, :official_site, :tags_text,
              :content, :description, photo_ids: [])
  end

  def set_categories
    @categories = Category.gt(things_count: 10)
  end
end
