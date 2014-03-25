# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location
  before_action :set_editor_choices, only: [:index]

  def index
    if user_signed_in?
      @activities = current_user.relate_activities.visible.page(params[:page]).per(50)

      if request.xhr?
        if @activities.empty?
          head :no_content
        else
          render 'home/index_xhr', layout: false
        end
      else
        if @activities.empty?
          @activities = Activity.visible.where(:type.in => %i(new_thing own_thing fancy_thing)).limit(50)
        end
        render 'home/index', layout: 'home'
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
    q.gsub!(/[^\u4e00-\u9fa5a-zA-Z0-9[:blank:].-]+/, '')

    if resultable = q.present?
      @things = Thing.unscoped.published.or({title: /#{q}/i}, {subtitle: /#{q}/i}).desc(:fanciers_count).page(params[:page]).per(12)
      resultable = @things.any?
    end

    respond_to do |format|
      if resultable
        format.html
        format.js
        format.json
      else
        format.html
        format.js { head :no_content }
        format.json { head :no_content }
      end
    end
  end

  def join_alpha
    cookies[:alpha] = { value: "pay", expires: 1.month.from_now }
    redirect_to root_path
  end

  def leave_alpha
    cookies.delete :alpha
    redirect_to root_path
  end

  def jobs
  end

  private

  def set_editor_choices
    @editor_choices = Thing.rand_prior_records 1
  end
end
