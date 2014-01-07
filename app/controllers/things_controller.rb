class ThingsController < ApplicationController
  include Commentable
  load_and_authorize_resource
  after_action :allow_iframe_load, only: [:show]

  # see home controller
  after_action only: [:index] do
    session[:previous_url] = things_url(sort: params[:sort])
  end
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

  def new
    @thing = Thing.new
  end

  def create
    @thing = Thing.new thing_params.merge(author: current_user)
    if @thing.save
      @thing.fancy current_user
      redirect_to @thing, flash: {provider_sync: params[:provider_sync]}
    else
      render 'new'
    end
  end

  def show
    @thing = Thing.find(params[:id]) || not_found
    read_comments @thing
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
    read_comments @thing
    render layout: 'thing'
  end

  private

  def thing_params
    params.require(:thing)
      .permit(:title, :subtitle, :official_site,
              :content, :description, photo_ids: [])
  end
end
