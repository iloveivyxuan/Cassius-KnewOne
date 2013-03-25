class ThingsController < PostsController
  after_filter :store_location, only: [:show]

  def index
    begin
      @date = Date.parse params[:date] if params[:date]
    rescue ArgumentError
      not_found
    end
    @date ||= Date.today
    @ndate = @date.next_day
    @things = Thing.where(created_at: (@date..@ndate))

    respond_to do |format|
      format.html
      format.json {@things = Thing.ne(shop: "")}
    end
  end

  def admin
    @things = Thing.page params[:page]
  end

  def new
    @thing = Thing.new
  end

  def create
    @thing = Thing.new params[:thing].merge(author: current_user)
    if @thing.save
      @thing.fancy current_user
      redirect_to @thing
    else
      render 'new'
    end
  end

  def show
    @thing = Thing.find(params[:id]) || not_found
    @reviews = @thing.reviews.limit(5)
    render layout: 'thing'
  end

  def edit
    if params[:admin] and can? :manage, :all
      render 'edit_admin'
    else
      @photos = @thing.photos.map(&:to_jq_upload)
      render 'new'
    end
  end

  def update
    if @thing.update_attributes(params[:thing])
      redirect_to @thing
    else
      render(params[:admin] ? 'edit_admin' : 'new')
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
    redirect_to @thing.shop
  end
end
