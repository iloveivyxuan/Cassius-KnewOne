class UpdatesController < PostsController
  load_and_authorize_resource :thing
  layout 'thing'

  def index
    @updates = @thing.updates.page params[:page]
  end

  def show
    read_comments @update
  end

  def new
    @update = Update.new
  end

  def create
    @update = Update.new params[:update]
      .merge(author: current_user, thing: @thing)
    if @update.save
      redirect_to thing_update_path(@thing, @update)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @update.update_attributes(params[:update])
      redirect_to thing_update_path(@thing, @update)
    else
      flash.now[:error] = @update.errors.full_messages.first
      render 'new'
    end
  end

  def destroy
    @update.destroy
    redirect_to @thing
  end
end
