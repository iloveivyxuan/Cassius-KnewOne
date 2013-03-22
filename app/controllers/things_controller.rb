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
  end

  def admin
    @things = Thing.all
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
      render "_fancy_button", locals: {thing: @thing}, layout: false
    else
      @thing.fancy current_user
      render "_unfancy_button", locals: {thing: @thing}, layout: false
    end

  end

  def own
    if @thing.owned? current_user
      @thing.unown current_user
      render "_own_button", locals: {thing: @thing}, layout: false
    else
      @thing.own current_user
      render "_unown_button", locals: {thing: @thing}, layout: false
    end
  end

  def buy
    redirect_to @thing.shop
  end
end
