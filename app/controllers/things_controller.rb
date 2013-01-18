class ThingsController < PostsController
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
    @thing = Thing.find(params[:id]) || not_found
  end

  def edit
    @thing = Thing.find(params[:id])
    @photos = @thing.photos.map(&:to_jq_upload)
    render 'new'
  end

  def update
    @thing = Thing.find params[:id]
    if @thing.update_attributes(params[:thing])
      redirect_to @thing
    else
      render 'new'
    end
  end

end
