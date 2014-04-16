class TopicsController < ApplicationController
  include MarkReadable
  load_and_authorize_resource :group, singleton: true
  load_and_authorize_resource :topic, through: :group
  layout 'group'
  after_action :allow_iframe_load, only: [:show]

  def show
    mark_read @topic
  end

  def new
  end

  def create
    @topic.author = current_user
    if @topic.save
      current_user.log_activity :new_topic, @topic, source: @topic.group
      redirect_to group_topic_url(@topic.group, @topic)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @topic.update topic_params
      redirect_to group_topic_url(@topic.group, @topic)
    else
      render 'new'
    end
  end

  def destroy
    @topic.destroy
    redirect_to group_url(@group)
  end

  def vote
    # TODO: same with reviews#vote, should be DRY
    if params[:vote] == "true"
      @topic.vote current_user, true
      current_user.log_activity :love_topic, @topic, source: @topic.group
    else
      @topic.vote current_user, false
    end
    render partial: 'voting', locals: {topic: @topic}, layout: false
  end

  private

  def topic_params
    permit_attrs = [:title, :content]
    permit_attrs << :is_top if current_user.role? :editor
    params.require(:topic).permit permit_attrs
  end
end
