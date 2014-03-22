class GroupsController < ApplicationController
  load_and_authorize_resource

  def index
    @groups = Group.all
  end

  def show
    @topics = @group.topics.page(params[:page]).per(20)
    render layout: 'group'
  end

  def new
  end

  def create
    @group = Group.new(group_params)
    @group.members.add current_user, :founder
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

  def join
    if @group.private?
      user = User.find params[:user_id]
      if params[:sign] != sign_invitation(@group, user)
        return redirect_to '/403'
      end
    end

    @group.members.add current_user
    redirect_to @group
  end

  def leave
    @group.members.remove current_user
    redirect_to @group
  end

  def invite
    @receiver = User.find params[:invite_user_id]

    if @receiver
      @link = if @group.public?
                join_group_url @group
              else
                make_private_invitation @group, @receiver
              end
      content = render_to_string '_invitation_private_message', layout: false
      current_user.send_private_message_to @receiver, content
    end

    respond_to do |format|
      format.js {}
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, :description, :avatar, :avatar_cache, :qualification)
  end

  def make_private_invitation(group, user)
    "#{join_group_url(group)}?user_id=#{user.id}&sign=#{sign_invitation(group, user)}"
  end

  def sign_invitation(group, user)
    Digest::MD5.hexdigest "#{group.id}#{Settings.invitation.secret}#{user.id}"
  end
end
