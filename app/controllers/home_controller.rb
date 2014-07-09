class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location
  before_action :set_editor_choices, only: [:index]
  before_action :skip_follow_user, only: [:index]
  before_action :authenticate_user!, only: [:welcome]

  def index
    if user_signed_in?
      session[:home_filter] = (params[:filter] or session[:home_filter])

      case session[:home_filter]
      when "followings"
        @activities = current_user.relate_activities
          .visible.page(params[:page]).per(50)
      when "things"
        @activities = Activity.by_types(:new_thing)
          .visible.page(params[:page]).per(30)
      when "posts"
        @activities = Activity.by_types(:new_review, :new_feeling, :new_topic)
          .visible.page(params[:page]).per(30)
      else
        @activities = Activity.by_types(:new_thing, :new_review, :new_feeling, :new_topic)
          .visible.page(params[:page]).per(30)
      end

      if request.xhr?
        render 'home/index_xhr', layout: false
      else
        render layout: 'home'
      end
    else
      respond_to do |format|
        format.html.mobile do
          @things = Thing.published.hot.limit(30)
          render 'home/landing.html+mobile'
        end

        format.html.tablet do
          @things = Thing.published.hot.limit(32)
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
  end

  def forbidden
    if user_signed_in?
      render 'home/forbidden_signed_in'
    else
      render 'home/forbidden'
    end
  end

  def welcome
    @friends = current_user.recommend_users || []
    @recommend_users = User.active_users(42) - @friends

    @things = Thing.published.prior.limit(24)
  end

  def error
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

  private

  def set_editor_choices
    #@editor_choices = Thing.rand_prior_records 1
    @editor_choices = Thing.published.prior.limit(1)
  end

  def skip_follow_user
    session[:skip] = true if params[:skip].present?
  end
end
