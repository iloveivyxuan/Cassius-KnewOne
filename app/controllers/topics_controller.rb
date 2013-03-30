class TopicsController < PostsController
  load_and_authorize_resource :group
  layout 'group'

  def show
    if user_signed_in?
      CommentMessage.read_by_post(current_user, @topic)
    end
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new params[:topic]
      .merge(author: current_user, group: @group)
    if @topic.save
      redirect_to group_topic_path(@group, @topic)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @topic.update_attributes(params[:topic])
      redirect_to group_topic_path(@group, @topic)
    else
      render 'new'
    end
  end

  def destroy
    @topic.destroy
    redirect_to group_path(@group)
  end
end
