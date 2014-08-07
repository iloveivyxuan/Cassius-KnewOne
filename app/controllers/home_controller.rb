class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location
  before_action :authenticate_user!, only: [:welcome]

  def index
    if user_signed_in?
      @source = (params[:source] or session[:source] or "following")
      @source = "recommended" if current_user.followings_count == 0
      session[:source] = @source

      if @source == "recommended"
        things = Thing.hot.page(params[:page]).per(30)
        reviews = Review.hot.page(params[:page]).per(5)
        @feeds = HomeFeed.create_from_things_and_reviews(things, reviews)
        @pager = things
      elsif @source == "following"
        activities = current_user.relate_activities(%i(new_thing own_thing fancy_thing
                                                        new_review love_review
                                                        new_feeling))
        activities = activities.page(params[:page]).per(30)
        @feeds = HomeFeed.create_from_activities activities
        @pager = activities
      end
    else
      respond_to do |format|
        format.html.mobile do
          hits
          render 'home/landing.html+mobile'
        end

        format.html.tablet do
          hits
          render 'home/landing.html+mobile'
        end

        format.html.desktop do
          @categories = Category.prior.gt(things_count: 10).limit(8)
          render 'home/landing'
        end
      end
    end
  end

  def hits
    @batch = 5
    @things = Thing.hot.page(params[:page]).per(6*@batch)
    @reviews = Review.hot.page(params[:page]).per(@batch)
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
    @recommend_users = User.active_users(42) - @friends
    @things = Thing.published.prior.limit(24)
  end

  def error
    respond_to do |format|
      format.js { head :internal_server_error }
      format.json { head :internal_server_error }
      format.html { render status: :internal_server_error }
    end
  end

  def search
    q = (params[:q] || '')
    q.gsub!(/[^\u4e00-\u9fa5a-zA-Z0-9[:blank:].-_]+/, '')
    q = Regexp.escape(q)

    return head :no_content if q.empty?
    per = params[:per_page] || 48

    if (params[:type].blank? && params[:format].blank?) || !['things', 'users', nil].include?(params[:type])
      params[:type] = 'things'
    end

    if params[:type].blank? || params[:type] == 'things'
      @things = Thing.published.or({slug: /#{q}/i}, {title: /#{q}/i}, {subtitle: /#{q}/i}).desc(:fanciers_count).page(params[:page]).per(per)
    end

    if params[:type].blank? || params[:type] == 'users'
      @users = User.find_by_fuzzy(q).page(params[:page]).per(per)
    end

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
end
