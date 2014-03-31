# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location
  before_action :set_editor_choices, only: [:index]
  before_action :skip_follow_user, only: [:index]

  def index
    if user_signed_in?
      if current_user.followings.empty? && !session[:skip]
        if @friends = current_user.recommend_users
          @friends = @friends.page(params[:friends_page]).per(21)
        end

        @recommend_users = User.desc(:recommend_priority, :followers_count).limit(21)

        render 'home/index_nofollowing', layout: 'home'
      else
        @activities = current_user.relate_activities.visible.page(params[:page]).per(50)

        if request.xhr?
          if @activities.empty?
            head :no_content
          else
            render 'home/index_xhr', layout: false
          end
        else
          render layout: 'home'
        end
      end
    else
      @landing_cover = LandingCover.find_for_home

      if @landing_cover.nil?
        redirect_to random_things_path
      else
        @categories = Category.gt(things_count: 10).limit(8)
        render 'home/landing'
      end
    end
  end

  def sandbox
    @things = Thing.prior.page(params[:page]).per(24)
    @reviews = Review.unscoped.desc(:created_at).limit(25)
    render layout: 'home'
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

  def error
  end

  def search
    q = (params[:q] || '')
    q.gsub!(/[^\u4e00-\u9fa5a-zA-Z0-9[:blank:].-_]+/, '')

    return head :no_content if q.empty?
    per = params[:per_page] || 24

    if (params[:type].blank? && params[:format].blank?) || !['things', 'users', nil].include?(params[:type])
      params[:type] = 'things'
    end

    if params[:type].blank? || params[:type] == 'things'
      @things = Thing.unscoped.published.or({title: /#{q}/i}, {subtitle: /#{q}/i}).desc(:fanciers_count).page(params[:page]).per(per)
    end

    if params[:type].blank? || params[:type] == 'users'
      @users = User.find_by_fuzzy_name(q).page(params[:page]).per(per)
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

  private

  def set_editor_choices
    @editor_choices = Thing.rand_prior_records 1
  end

  def skip_follow_user
    session[:skip] = true if params[:skip].present?
  end
end
