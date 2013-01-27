class HomeController < ApplicationController
  def index
    @things = Thing.gte(priority: 0)
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
