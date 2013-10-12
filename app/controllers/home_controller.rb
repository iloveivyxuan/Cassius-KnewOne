# -*- coding: utf-8 -*-
class HomeController < ApplicationController
  def index
    @things = Thing.prior.page(params[:page]).per(20)
    @new_things = Thing.published.limit(10)
    @new_reviews = Review.unscoped.desc(:created_at).limit(20)
  end

  def qr_entry
    redirect_to "sinaweibo://userinfo?uid=3160959662"
  end

  def sandbox
  end

  def not_found
  end

  def forbidden
  end

  def search
    redirect_to "https://www.google.com.hk/#hl=zh-CN&q=site:#{Settings.host}+#{params[:q]}"
  end

  def join_alpha
    cookies[:alpha] = "pay"
    redirect_to root_path
  end

  def leave_alpha
    cookies.delete :alpha
    redirect_to root_path
  end
end
