# -*- coding: utf-8 -*-
class GroupsController < ApplicationController
  load_and_authorize_resource
  after_filter :store_location, only: [:show]

  def index
    can? :manage, :all or not_found
    @groups = Group.classic
  end

  def show
    @topics = @group.topics.page params[:page]
    render layout: 'group'
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(params[:group])
    @group.founder = current_user
    if @group.save
      redirect_to groups_path
    else
      render 'new'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @group.update(params[:group])
      redirect_to group_path(@group)
    else
      render 'new'
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path
  end
end
