# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  layout 'application'

  # seems infinite scroll request page data as HTML, store_location will store it as previous_url
  # sign in will redirect to like /page/9, it confused.
  # the error should occur in things#index
  after_action only: [:index] do
    session[:previous_url] = root_url
  end
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
    @things = Thing.published.prior.where(title: /^#{params[:q]}/i).page(params[:page])

    respond_to do |format|
      format.html
      format.js
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
