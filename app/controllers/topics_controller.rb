# -*- coding: utf-8 -*-
class TopicsController < PostsController
  load_and_authorize_resource :group
  layout 'group'

  def show
    read_comments @topic
  end

  def new
    @topic = Topic.new
  end

  def create
    @topic = Topic.new topic_params
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
    if @topic.update topic_params
      redirect_to group_topic_path(@group, @topic)
    else
      render 'new'
    end
  end

  def destroy
    @topic.destroy
    redirect_to group_path(@group)
  end

  private

  def topic_params
    permit_attrs = [:title, :content]
    permit_attrs << :is_top if current_user.role? :editor
    params.require(:topic).permit permit_attrs
  end
end
