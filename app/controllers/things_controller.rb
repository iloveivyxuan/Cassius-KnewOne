class ThingsController < ApplicationController
  include MarkReadable
  load_and_authorize_resource
  after_action :allow_iframe_load, only: [:show]
  after_action :store_location, only: [:comments, :show]

  def index
    per = (params[:per] || 24).to_i

    scope = case params[:sort]
            when "self_run"
              Thing.self_run
            when "fancy"
              Thing.unscoped.published.desc(:fanciers_count)
            when "random"
              Thing.rand_records per
            else
              Thing.published
            end

    if params[:sort] == "random"
      @things = Kaminari.paginate_array(scope).page(params[:page])
    else
      @things = scope.page(params[:page]).per(per)
    end

    respond_to do |format|
      format.html
      format.atom
      format.json
    end
  end

  def random
    @things = Thing.rand_records (params[:per] || 24).to_i

    respond_to do |format|
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

  def group_fancy
    @group = if params[:group_id].present?
               Group.find params[:group_id]
             else
               Group.where(name: params[:group_name]).first
             end

    @group.has_member? current_user and @group.fancy @thing
    respond_to { |format| format.js }
  end

  private

  def thing_params
    params.require(:thing)
      .permit(:title, :subtitle, :official_site,
              :content, :description, photo_ids: [])
  end
end
