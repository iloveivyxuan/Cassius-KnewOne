class GroupsController < ApplicationController
  load_and_authorize_resource

  def index
    @groups = Group.all
  end

  def show
    @topics = @group.topics.page params[:page]
    render layout: 'group'
  end

  def new
  end

  def create
    @group = Group.new(group_params)
    @group.members.add current_user, :admin
    if @group.save
      redirect_to group_path(@group)
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
