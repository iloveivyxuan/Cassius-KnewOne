class ThingsController < PostsController
  after_filter :store_location, only: [:show]

  def index
    scope = case params[:sort]
            when "self_run"
              Thing.self_run
            when "fancy"
              Thing.unscoped.published.desc(:fanciers_count)
            when "random"
              # TODO: may need optimize
              size = Thing.published.size
              Thing.published.skip(rand(size))
            else
              Thing.published
            end

    @things = scope.page(params[:page]).per(params[:per] || 12)

    respond_to do |format|
      format.html
      format.atom
      format.json
    end
  end

  def admin
    if params[:can_buy]
      @things = Thing.ne(shop: "").page params[:page]
    else
      @things = Thing.page params[:page]
    end
  end

  def new
    @thing = Thing.new
  end

  def create
    @thing = Thing.new params[:thing].merge(author: current_user)
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
    if @thing.update_attributes(params[:thing])
      redirect_to @thing
    else
      render 'new'
    end
  end

  def destroy
    @thing.destroy
    redirect_to root_path
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

  def pro_edit
  end

  def pro_update
    if @thing.update_attributes(params[:thing])
      redirect_to @thing
    else
      render 'pro_edit'
    end
  end

  def resort
    Thing.resort!

    redirect_to admin_things_path
  end
end
