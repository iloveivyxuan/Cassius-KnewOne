class UsersController < ApplicationController
  load_and_authorize_resource except: [:fuzzy]

  def show
    @fancies = @user.fancies_sorted_by_ids(1, 3)
    @owns = @user.owns_sorted_by_ids(1, 3)
    @lists = @user.thing_lists.desc(:fanciers_count).limit(3)
    @reviews = @user.reviews.desc(:is_top, :lovers_count, :created_at).where(:thing_id.ne => nil).limit(2)
    @feelings = @user.feelings.desc(:lovers_count, :created_at).where(:thing_id.ne => nil).limit(2)
    @activities = @user.activities.visible.limit(10)
  end

  def fancies
    @fancies = @user.fancies_sorted_by_ids(params[:page], 24)
  end

  def owns
    @owns = @user.owns_sorted_by_ids(params[:page], 24)
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
    @activities = @user.activities.visible.page(params[:page]).per(24)
  end

  def followings
    @followings = @user.followings.page(params[:page]).per(24)
  end

  def followers
    @followers = @user.followers.page(params[:page]).per(24)
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
end
