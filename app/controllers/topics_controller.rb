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
    if @topic.update(params[:topic])
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
