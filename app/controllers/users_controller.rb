class UsersController < ApplicationController
  load_and_authorize_resource except: [:fuzzy]

  def show
    redirect_to activities_user_url
  end

  def fancies
    @impressions = @user.impressions.fancied
    setup_tags_and_things_about_impressions
  end

  def desires
    @impressions = @user.impressions.desired
    setup_tags_and_things_about_impressions
  end

  def owns
    @impressions = @user.impressions.owned
    setup_tags_and_things_about_impressions
  end

  def lists
    @filter = params[:filter] || 'owned'

    if @filter == 'fancied'
      @lists = @user.fancied_thing_lists
    else
      @lists = @user.thing_lists
    end

    @lists = @lists.desc(:updated_at)
    @lists = @lists.page(params[:page]).per(24)
  end

  def reviews
    @reviews = @user.reviews.desc(:is_top, :lovers_count, :created_at).where(:thing_id.ne => nil).page(params[:page]).per(24)
  end

  def feelings
    @feelings = @user.feelings.desc(:lovers_count, :created_at).where(:thing_id.ne => nil).page(params[:page]).per(24)
  end

  def things
    @things = @user.things.desc(:created_at).page(params[:page]).per(24)
  end

  def groups
    @groups = Group.find_by_user(@user).page(params[:page]).per(24)
  end

  def topics
    @topics = @user.topics.page(params[:page]).per(20)
  end

  def activities
    @rich = params[:rich].to_s != 'false'
    @activities = @user.activities.visible.page(params[:page]).per(24)
  end

  def followings
    @followings = @user.followings_sorted_by_ids(params[:page], 24)
  end

  def followers
    @followers = @user.followers_sorted_by_ids(params[:page], 24)
  end

  def share
    return render js: "Making.ShowMessageOnTop('需要选择一个分享目标！', 'danger')" unless params[:providers]

    current_user.auths.where(:provider.in => params[:providers]).each do |auth|
      auth.share params[:share][:content], params[:share][:pic]
    end

    render js: "Making.ShowMessageOnTop('分享成功！')"
  end

  def follow
    current_user.follow @user
    current_user.log_activity :follow_user, @user, check_recent: true

    respond_to do |format|
      format.html { redirect_stored_or user_path(@user) }
      format.js
    end
  end

  def batch_follow
    user_ids = params[:user_ids].to_a.map(&:to_s) rescue []
    @users = User.in(id: user_ids)
    current_user.batch_follow(@users)

    respond_to do |format|
      format.js
    end
  end

  def unfollow
    current_user.unfollow @user

    respond_to do |format|
      format.html { redirect_stored_or user_path(@user) }
      format.js
    end
  end

  def fuzzy
    @users = User.find_by_sequence(params[:query])
    respond_to do |format|
      format.json do
        @users = @users.limit(20)
      end
    end
  end

  def profile
    render layout: false
  end

  def set_profile
    user = User.find params[:id]
    if user != current_user
      success = false
    elsif params[:canopy].present?
      success = user.update(canopy: params[:canopy]) ? true : false
    end
    head success ? :ok : :not_acceptable
  end

  private

  def setup_tags_and_things_about_impressions
    @tag = Tag.find(params[:tag]) if params[:tag].present?

    tag_ids = @user.tag_ids & @impressions.distinct(:tag_ids)
    @tags = Tag.in(id: tag_ids).sort_by { |t| t == @tag ? -1 : tag_ids.index(t.id) }

    @impressions = @impressions.by_tag(@tag) if @tag
    @impressions = @impressions.page(params[:page]).per(24)

    thing_ids = @impressions.pluck(:thing_id)
    @things = Thing.in(id: thing_ids).sort_by { |t| thing_ids.index(t.id) }
  end
end

