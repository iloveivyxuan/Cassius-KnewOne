# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location
  before_action :set_editor_choices, only: [:index]
  before_action :skip_follow_user, only: [:index]
  before_action :authenticate_user!, only: [:welcome]

  def index
    if user_signed_in?
      session[:home_filter] = (params[:filter] or session[:home_filter])
      session[:home_filter] ||= 'hot'
      @activities = []
      params[:page] ||= 0
      case session[:home_filter]
      when "followings"
        @activities = following_activities(params[:page])
      else
        @activities = hot_activities(params[:page])
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

  def sandbox
    @extracted_data = {
      images: %w(
          http://image.knewone.com/photos/bf156596dc73be8b743a76a1b9231d71.jpg
          http://image.knewone.com/photos/8cd9b1a51879a0cdde1866e2a0023a5c.jpg
          http://image.knewone.com/photos/3f4452a976ee852fd53b2ef52119b60d.jpg!review
        )
    }
    render layout: 'application'
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
    page ||= 0

    activities = current_user
      .relate_activities(%i(new_thing own_thing fancy_thing
                            new_review love_review new_feeling love_feeling))
      .visible
      .limit(60 + 20)
      .skip(page.to_i * 60)
      .to_a
      .uniq(&:reference_union)

    lcm = [2, 3, 4].inject(:lcm)
    activities.take(activities.size / lcm * lcm)
  end

  def hot_activities(page)
    page ||= 0
    things = Thing.hot.limit(30).skip(page.to_i * 30).to_a
    reviews = Review.hot.limit(30).skip(page.to_i * 30).to_a
    # 每次随机取产品或评测
    while (!things.empty? || !reviews.empty?) do
      rand = [true, false].sample
      if reviews.empty? || (rand && !things.empty?)
        t = things.shift
        @activities << Activity.new(
                                    type: :new_thing,
                                    reference_union: "Thing_#{t.id}",
                                    source_union: "Thing_#{t.id}",
                                    visible: true,
                                    user_id: t.author.id)
      else
        r = reviews.shift
        @activities << Activity.new(
                                    type: :new_review,
                                    reference_union: "Review_#{r.id}",
                                    source_union: "Thing_#{r.thing.id}",
                                    visible: true,
                                    user_id: r.author.id)
      end
    end
    @activities
  end
end
