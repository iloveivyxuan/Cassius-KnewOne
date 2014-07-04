class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location
  before_action :set_editor_choices, only: [:index]
  before_action :skip_follow_user, only: [:index]
  before_action :authenticate_user!, only: [:welcome]

  def index
    if user_signed_in?
      @activities = following_activities params[:page]

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
    @nums = {things: 6, reviews: 1, groups: 4}
    @things = Thing.hot.page(params[:page]).per(@nums[:things]*@nums[:groups])
    @reviews = Review.hot.page(params[:page]).per(@nums[:reviews]*@nums[:groups])
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
    @recommend_users = User.desc(:recommend_priority, :followers_count).limit(42) - @friends

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

  def following_activities(page)
    activities = current_user
      .relate_activities(%i(new_thing own_thing fancy_thing
                            new_review love_review new_feeling love_feeling),
                         %i(new_review))
      .visible
      .limit(60 + 20)
      .skip(page.to_i * 60)
      .to_a
      .uniq(&:reference_union)

    lcm = [2, 3, 4].inject(:lcm)
    activities.take(activities.size / lcm * lcm)
  end
end
