# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  layout 'application'

  def index
    @things = Thing.prior.page(params[:page]).per(24)
    @reviews = Review.unscoped.desc(:created_at).limit(25)

    if user_signed_in?
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
  end

  def not_found
  end

  def forbidden
  end

  def error
  end

  def search
    redirect_to "https://www.google.com.hk/#hl=zh-CN&q=site:#{Settings.host}+#{params[:q]}"
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
