class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location, except: [:index]
  before_action :authenticate_user!, only: [:welcome]

  def index
    if user_signed_in?
      @source = (params[:source] or session[:source] or "following")

      if @source == "following" and current_user.followings_count > 0
        session[:source] = @source
        activities = current_user.related_activities(%i(new_thing own_thing fancy_thing
                                                        new_review love_review
                                                        new_feeling
                                                        add_to_list fancy_list))
        activities = activities.page(params[:page]).per(30)
        @feeds = HomeFeed.create_from_activities activities
        @pager = activities
      else
        session[:source] = "latest"
        things = Thing.published.approved.desc(:approved_at)
        things = things.page(params[:page]).per(30)
        reviews = []
        @feeds = HomeFeed.create_from_things_and_reviews(things, reviews)
        @pager = things
      end
    else
      respond_to do |format|
        format.html.mobile do
          hits
          render 'home/landing.html+mobile' unless request.xhr?
        end

        format.html.tablet do
          hits
          render 'home/landing.html+mobile' unless request.xhr?
        end

        format.html.desktop do
          @categories = Category.primary.gt(things_count: 10).desc(:things_count)
          render 'home/landing'
        end
      end
    end
  end

  def hits
    @batch = 5
    @things = Thing.hot.approved.page(params[:page]).per(6*@batch)
    @reviews = Review.hot.page(params[:page]).per(@batch)
    @thing_lists = ThingList.hot.page(params[:page]).per(@batch)

    if request.xhr?
      render 'hits_xhr', layout: false
    end
  end

  def not_found
    respond_to do |format|
      format.js { head :not_found }
      format.json { head :not_found }
      format.html { render status: :not_found }
    end
  end

  def forbidden
    if user_signed_in?
      render 'home/forbidden_signed_in', status: :forbidden
    else
      render 'home/forbidden', status: :forbidden
    end
  end

  def blocked

  end

  def welcome
    @friends = current_user.recommend_users || []
    @categories = Category.desc(:things_count).limit(9)
  end

  def error
    respond_to do |format|
      format.js { head :internal_server_error }
      format.json { head :internal_server_error }
      format.html { render status: :internal_server_error }
    end
  end

  def search
    q = params[:q].to_s

    return head :no_content if q.empty?
    per = params[:per_page] || 48

    if (params[:type].blank? && params[:format].blank?) || !['things', 'users', nil].include?(params[:type])
      params[:type] = 'things'
    end

    if params[:type].blank? || params[:type] == 'things'
      @things = Thing.search(q).page(params[:page]).per(per).records
    end

    if params[:type].blank? || params[:type] == 'users'
      @users = User.search(q).page(params[:page]).per(per).records
    end

    @category = Category.search(q).limit(1).records.first
    @tag = Tag.search(q).limit(1).records.first
    @brand = Brand.search(q).limit(1).records.first

    respond_to do |format|
      format.html { render "home/search_#{params[:type]}", layout: 'search' }
      format.js
      format.json
    end
  end

  def qr_entry
    redirect_to "sinaweibo://userinfo?uid=3160959662"
  end

  def jobs
  end

  def user_agreement
  end

  def wxpay_alert
    logger.info params.except(*request.path_parameters.keys)
    head :no_content
  end

  def embed
    case params[:type]
    when 'list'
      @list = ThingList.find params[:id]
      render [@list], locals: { layout: browser.desktop? ? :quintet : :grid }
    when 'review'
      @review = Review.find params[:id]
      render partial: 'hot_review', collection: [@review]
    else
      head :unprocessable_entity
    end
  end
end
