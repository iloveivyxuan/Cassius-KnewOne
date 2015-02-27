class ThingsController < ApplicationController
  include MarkReadable
  include DestroyDraft

  load_and_authorize_resource
  before_action :set_categories, only: [:index]
  after_action :allow_iframe_load, only: [:show]
  after_action :store_location, only: [:comments, :show]

  def index
    if params[:categories].present?
      @top_c, @second_c, @third_c = params[:categories].split("/").map { |slug| Category.find(slug) }
      @category = @third_c || @second_c || @top_c
      @things = @category.things
    end

    if params[:brand].present?
      @brand = Brand.where(id: params[:brand].to_s).first
      @things = @things.by_brand(@brand) if @brand
    end

    if params[:sort_by] == 'fanciers_count'
      @things = @things.desc(:fanciers_count)
    else
      @things = @things.desc(:created_at)
    end

    if params[:categories].present? || params[:brand].present?
      @things = @things.approved
    else
      @things = @things.recommended
    end

    @things ||= Thing.all
    @things = @things.published.page(params[:page]).per((params[:per] || 24).to_i)

    respond_to do |format|
      format.html do
        if request.xhr?
          if @things.any?
            render @things
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
      category = Category.any_in(slugs: params[:categories]).first
      @things = category ? Thing.where(category_ids: category.id.to_s) : Thing.where(category_ids: "")
    end

    if params[:bong_point]
      @things = @things.or({ :'kinds.minimal_bong_point'.gt => 0 }, { :'kinds.maximal_bong_point'.gt => 0 })
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

  def new
    @thing = Thing.new
    if request.xhr?
      @thing.feelings.build
      render 'new_thing_in_modal', layout: false
    end
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

  def create_by_user
    @thing = Thing.new params.require(:thing).permit(:title, photo_ids: [], feelings_attributes: [:content]).merge(author: current_user)
    @thing.feelings.each do |feeling|
      @thing.feelings.delete feeling and next if feeling.content.blank?
      feeling.author = current_user
      feeling.content.gsub! /\r\n/, "\n"
    end

    if @thing.save
      @thing.fancy current_user
      current_user.log_activity :new_thing, @thing
      @thing.feelings.each { |feeling| feeling.notify_by current_user, mentioned_users(feeling.content) }
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
    end

    respond_to do |format|
      format.html { redirect_to @thing }
      format.js { head :no_content }
    end
  end

  def buy
    respond_to do |format|
      format.html { redirect_to @thing.shop }
      format.json { render json: {type: 'taobao', id: '25312892353'} } #fake
    end
  end

  ACTIVITY_TYPES = ['fancy_thing', 'desire_thing', 'own_thing', 'add_to_list']
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

  def lists
    @lists = @thing.lists.qualified.desc(:fanciers_count)
    @lists = @lists.page(params[:page]).per(24)

    respond_to do |format|
      format.html { render layout: 'application' }
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
      @thing.feelings.build
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

    @thing = Thing.new params.require(:thing).permit(:title, :official_site, feelings_attributes: [:content]).merge(author: current_user)
    @thing.content = @thing.content.gsub("\r", '').split("\n").compact.map { |l| "<p>#{l}</p>" }.join
    @thing.photo_ids.concat photos.map(&:id)

    @thing.feelings.each do |feeling|
      @thing.feelings.delete feeling and next if feeling.content.blank?
      feeling.author = current_user
      feeling.content.gsub! /\r\n/, "\n"
    end

    if @flag = @thing.save
      @thing.fancy current_user
      current_user.log_activity :new_thing, @thing
      @thing.feelings.each { |feeling| feeling.notify_by current_user, mentioned_users(feeling.content) }
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

  def modify_brand
    @brand = Brand.find(params[:brand_id])
    @brand.update(brand_params)
    @brand.save

    redirect_to brand_things_path(@brand.id.to_s)
  end

  private

  def thing_params
    permit_params = [:title, :subtitle, :official_site, :tags_text, :content, :description, photo_ids: []]
    @thing ||= Thing.new
    if (@thing.author == current_user || !@thing.persisted?) && current_user.role?(:volunteer)
      permit_params += [:shop, :price_unit, :price]
    end
    params.require(:thing).permit(permit_params)
  end

  def set_categories
    @categories = Category.gt(things_count: 10)
  end

  def brand_params
    if current_user.role?(:volunteer)
      params.require(:brand).permit([:zh_name, :en_name, :logo, :logo_cache, :description, :nickname, :country])
    end
  end
end
