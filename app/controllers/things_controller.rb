class ThingsController < ApplicationController
  include MarkReadable
  include DestroyDraftAfterCreate

  load_and_authorize_resource
  before_action :set_categories, only: [:index]
  after_action :allow_iframe_load, only: [:show]
  after_action :store_location, only: [:comments, :show]

  def index
    if params[:category].present? and params[:category] != 'all'
      @category = Category.find(params[:category])
      @things = @category.things.published
    else
      @things = Thing.published
    end

    if params[:stage].present?
      @things = @things.where(stage: params[:stage])
    end

    @things = @things.self_run if params[:self_run].present?

    if params[:sort_by] == 'fanciers_count'
      @things = @things.desc(:fanciers_count)
    else
      @things = @things.desc(:created_at)
    end

    @things = @things.page(params[:page]).per((params[:per] || 24).to_i)

    respond_to do |format|
      format.html
      format.atom
      format.json
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
      format.html.mobile
      format.html.tablet { render layout: 'thing' }
      format.html.desktop { render layout: 'thing' }
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

  def comments
    mark_read @thing
    render layout: 'thing'
  end

  def related
    @things = @thing.related_things
  end

  def group_fancy
    @group = if params[:group_id].present?
               Group.find params[:group_id]
             else
               Group.where(name: params[:group_name]).first
             end

    @group and @group.has_member? current_user and @group.fancy @thing

    respond_to { |format| format.js }
  end

  def groups
    @groups = @thing.fancy_groups.page(params[:page]).per(24)
    render layout: 'thing'
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
    if thing.id.to_s == "53d0bed731302d2c13b20000" # bong II
      @rebate_coupon = ThingRebateCoupon.find_or_create_by(
                                                           name: "bong II 10 元优惠券",
                                                           thing_id: thing.id.to_s,
                                                           note: "结算时输入优惠券代码立减 10 元",
                                                           price: 10.0)
      @rebate_coupon.update_attributes(max_amount: 1000) if @rebate_coupon.max_amount.nil?
      if !current_user_has_got_coupon_code? && @rebate_coupon.has_remaining?
        coupon_code = @rebate_coupon.generate_code!(
                                                    user: current_user,
                                                    expires_at: 1.year.since.to_date,
                                                    admin_note: "通过领取 bong II 优惠券获得",
                                                    generator_id: current_user.id.to_s)
      else
        flash[:notice] = "优惠券已被领完或您已经领过"
      end
    end # bong II
    redirect_to coupons_url
  end

  private

  def thing_params
    params.require(:thing)
    .permit(:title, :subtitle, :official_site,
            :content, :description, photo_ids: [])
  end

  def set_categories
    @categories = Category.gt(things_count: 10)
  end

  def current_user_has_got_coupon_code?
    current_user.coupon_codes.where(coupon_id: @rebate_coupon.id.to_s).exists?
  end

end
