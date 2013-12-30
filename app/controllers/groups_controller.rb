# -*- coding: utf-8 -*-
class GroupsController < ApplicationController
  load_and_authorize_resource
  layout 'settings', except: [:show]

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
    @group = Group.new(group_params)
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
    if @group.update(group_params)
      redirect_to group_path(@group)
    else
      render 'new'
    end
  end

  def destroy
    @group.destroy
    redirect_to groups_path
  end

  private

  def group_params
    params.require(:group).permit(:name, :description)
  end
end
