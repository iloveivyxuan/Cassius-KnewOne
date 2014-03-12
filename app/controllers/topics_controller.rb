# -*- coding: utf-8 -*-
class TopicsController < ApplicationController
  include MarkReadable
  load_and_authorize_resource :group, singleton: true
  load_and_authorize_resource :topic, through: :group
  layout 'group'
  after_action :allow_iframe_load, only: [:show]

  def index
    @topics = @topics.page params[:page]
  end

  def show
    mark_read @topic
  end

  def new
  end

  def create
    @topic.author = current_user
    if @topic.save
      flash[:provider_sync] = params[:provider_sync]
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
    redirect_to group_path(@group)
  end

  private

  def topic_params
    permit_attrs = [:title, :content]
    permit_attrs << :is_top if current_user.role? :editor
    params.require(:topic).permit permit_attrs
  end
end
