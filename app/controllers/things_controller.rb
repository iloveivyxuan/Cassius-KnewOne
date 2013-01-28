class ThingsController < PostsController
  def index
    @things = Thing.all
    respond_to do |format|
      format.html {redirect_to root_path}
      format.json
    end
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
      redirect_to @thing
    else
      render 'new'
    end
  end

  def show
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

end
