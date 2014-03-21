class ThingsController < ApplicationController
  include MarkReadable
  load_and_authorize_resource
  before_action :set_categories, only: [:index]
  after_action :allow_iframe_load, only: [:show]
  after_action :store_location, only: [:comments, :show]

  def index
    if params[:category].present?
      @things = Category.find(params[:category]).things
    else
      @things = Thing.published
    end

    @things = @things.self_run if params[:self_run]
    @things = @things.prior if params[:sort_by] != 'created_at'

    case params[:price_range]
      when '1-199'
        @things = @things.price_between(1, 199)
      when '200-499'
        @things = @things.price_between(200, 499)
      when '500-999'
        @things = @things.price_between(500, 999)
      when 'emperor'
        @things = @things.or({:price.gt => 1000}, {:'kind.price'.gt => 1000})
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
      format.js
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
