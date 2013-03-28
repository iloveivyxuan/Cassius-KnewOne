class TopicsController < PostsController
  load_and_authorize_resource :group

  def show
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
    redirect_to group_topics_path(@group)
  end
end
