class ThingsController < PostsController
  def new
    @thing = Thing.new
  end

  def create
    @photo_ids = params[:thing].delete :photo_ids
    @thing = Thing.new params[:thing]
    @thing.author = current_user
    if !@photo_ids.blank? && @thing.save
      @thing.photos = Photo.find @photo_ids
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
    photo_ids = params[:thing].delete :photo_ids
    @thing = Thing.find params[:id]
    params[:thing][:photos] = Photo.find photo_ids
    if @thing.update_attributes(params[:thing])
      redirect_to @thing
    else
      render 'new'
    end
  end

end
