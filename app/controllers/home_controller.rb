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
      render file: 'home/landing'
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
    q = (params[:q] || '')
    q.gsub!(/[^\u4e00-\u9fa5a-zA-Z0-9[:blank:].-]+/, '')

    if resultable = q.present?
      @things = Thing.published.or({title: /#{q}/i}, {subtitle: /#{q}/i}).page(params[:page]).per(12)
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

end
