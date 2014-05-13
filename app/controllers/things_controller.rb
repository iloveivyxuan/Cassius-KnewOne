class ThingsController < ApplicationController
  include MarkReadable
  load_and_authorize_resource
  before_action :set_categories, only: [:index]
  after_action :allow_iframe_load, only: [:show]
  after_action :store_location, only: [:comments, :show]

  def index
    if params[:category].present? and params[:category] != 'all'
      @category = Category.find(params[:category])
      @things = @category.things.unscoped.published
    else
      @things = Thing.unscoped.published
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
    @thing = Thing.find(params[:id]) || not_found
    mark_read @thing
    render layout: 'thing'
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
      @thing = Thing.new official_site: @result[:url],
                         title: @result[:title],
                         content: @result[:content]

      @similar = Thing.unscoped.published.or({slug: /#{@result[:title]}/i},
                                           {title: /#{@result[:title]}/i},
                                           {subtitle: /#{@result[:title]}/i},
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
    @thing.photo_ids.concat photos.map(&:id)

    if @flag = @thing.save
      @thing.fancy current_user
      current_user.log_activity :new_thing, @thing
    end

    respond_to do |format|
      format.js
    end
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
end
