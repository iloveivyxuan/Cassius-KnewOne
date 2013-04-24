class LinksController < PostsController
  load_and_authorize_resource :thing
  layout 'thing'

  def index
    @links = @thing.links.page params[:page]
  end

  def show
    if user_signed_in?
      CommentMessage.read_by_post(current_user, @link)
    end
  end

  def new
    @link = Link.new
  end

  def create
    @link = Link.new params[:link]
      .merge(author: current_user, thing: @thing)
    if @link.save
      redirect_to thing_links_path(@thing)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @link.update_attributes(params[:link])
      redirect_to thing_link_path(@thing, @link)
    else
      flash.now[:error] = @link.errors.full_messages.first
      render 'new'
    end
  end

  def destroy
    @link.destroy
    redirect_to @thing
  end

  def digg
    @link.digg current_user
    respond_to do |format|
      format.html { redirect_to @link }
      format.js
    end
  end
end
