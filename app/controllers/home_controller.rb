class HomeController < ApplicationController
  def index
    @things = Thing.unscoped.published.gt(priority: 0).desc(:priority, :created_at)
    @new_things = Thing.published.limit(5)
    @new_reviews = Review.unscoped.desc(:created_at).limit(10)
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
end
