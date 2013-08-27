class FeaturesController < PostsController
  load_and_authorize_resource :thing
  layout 'thing'

  def index
  end

  def show
  end

  def new
    authorize! :update, @thing
    @feature = Feature.new
  end

  def create
    authorize! :update, @thing
    @feature = Feature.new params[:feature]
      .merge(author: current_user, thing: @thing)
    if @feature.save
      redirect_to thing_features_path(@thing)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @feature.update_attributes(params[:feature])
      redirect_to thing_features_path(@thing)
    else
      render 'new'
    end
  end

  def destroy
    @feature.destroy
    redirect_to thing_features_path(@thing)
  end
end
