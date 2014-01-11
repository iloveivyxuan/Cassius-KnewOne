# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  layout 'application'
  skip_after_action :store_location

  def index
    @things = Thing.prior.page(params[:page]).per(28)
    @reviews = Review.unscoped.desc(:created_at).limit(15)

    @landing_page = LandingPage.find_for_home

    if user_signed_in? || @landing_page.nil?
      render 'home/index'
    else
      render file: 'home/landing', layout: 'home'
    end
  end

  def qr_entry
    redirect_to "sinaweibo://userinfo?uid=3160959662"
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
    respond_to do |format|
      if params[:q].present?
        q = params[:q].gsub /[^\u4e00-\u9fa5a-zA-Z0-9\s-]+/, ''
        @things = Thing.published.or({title: /#{q}/i}, {subtitle: /#{q}/i}).page(params[:page]).per(12)

        format.html
        format.js
      else
        format.html { redirect_to things_path }
        format.js { head :no_content }
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

end
