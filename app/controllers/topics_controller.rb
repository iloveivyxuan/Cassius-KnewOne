class TopicsController < ApplicationController
  include MarkReadable
  load_and_authorize_resource :group, singleton: true
  load_and_authorize_resource :topic, through: :group
  layout 'group'
  after_action :allow_iframe_load, only: [:show]
  before_action :forbidden_invisible, only: [:show]

  def show
    mark_read @topic
  end

  def new
  end

  def create
    @topic.author = current_user
    if @topic.save
      # notify mentioned users when there is new topic
      title_users, content_users = mentioned_users(@topic.title), mentioned_users(@topic.content)
      (title_users + content_users).each do |u|
        u.notify :topic, context: @topic, sender: current_user, opened: false
      end

      current_user.log_activity :new_topic, @topic, source: @topic.group
      redirect_to group_topic_path(@topic.group, @topic)
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @topic.update topic_params
      redirect_to group_topic_path(@topic.group, @topic)
    else
      render 'new'
    end
  end

  def destroy
    @topic.destroy
    current_user.log_activity :delete_topic, @topic, visible: false
    redirect_to group_path(@group)
  end

  def vote
    @topic.vote(current_user)

    current_user.log_activity :love_topic, @topic, source: @topic.group

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @topic} }
    end
  end

  def unvote
    @topic.unvote(current_user)

    respond_to do |format|
      format.js { render partial: 'shared/vote', locals: {object: @topic} }
    end
  end

  private

  def topic_params
    permit_attrs = [:title, :content]
    if current_user && current_user.can_set_topic_top?(@group)
      permit_attrs << :is_top
    end
    params.require(:topic).permit permit_attrs
  end

  def forbidden_invisible
    group = Group.find params[:group_id]
    unless group.visible
      if current_user.nil? || !group.members.where(user_id: current_user.id.to_s).exists?
        raise ActionController::RoutingError.new('Not Found')
      end
    end
  end
end
