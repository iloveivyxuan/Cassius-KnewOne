class GroupsController < ApplicationController
  load_and_authorize_resource

  def index
    @groups = Group.desc(:members_count).limit(10)
    @topics = Topic.unscoped.desc(:commented_at).page(params[:page]).per(20)
  end

  def all
    @groups = Group.desc(:members_count).page(params[:page]).per(24)
  end

  def show
    @topics = @group.topics.page(params[:page]).per(20)
    render layout: 'group'
  end

  def new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      @group.members.add current_user, :founder
      redirect_to group_path(@group)
    else
      render 'new'
    end
  end

  def edit
    render 'new', layout: 'group'
  end

  def update
    if @group.update(group_params)
      redirect_to group_path(@group)
    else
      render 'new', layout: 'group'
    end
  end

  def destroy
    @group.destroy
    current_user.log_activity :delete_group, @group, visible: false
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
    @receiver = if params[:invite_user_id].present?
                 User.find params[:invite_user_id]
               else
                 User.where(name: params[:invite_user_name]).first
               end

    if @receiver
      @link = if @group.public?
                join_group_url @group
              else
                make_private_invitation @group, @receiver
              end
      content = render_to_string '_invitation_private_message', layout: false
      current_user.send_private_message_to @receiver, content
    end

    respond_to { |format| format.js }
  end

  def members
    @members = @group.members.page(params[:page]).per(96)
    render layout: 'group'
  end

  def fancies
    @things = @group.fancies.page(params[:page]).per(24)
    render layout: 'group'
  end

  def fuzzy
    @groups = Group.find_by_fuzzy_name(params[:query])
    respond_to do |format|
      format.json { @groups = @groups.limit(20) }
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
