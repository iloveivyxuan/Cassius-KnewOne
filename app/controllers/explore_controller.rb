class ExploreController < ApplicationController
  skip_before_action :require_not_blocked
  helper :entries
  before_action :set_page

  def index
    @entries = Entry.published.not.in(category: %w(活动 特写)).desc(:created_at).page(params[:page]).per(@per)

    respond_to do |format|
      format.html
      format.atom
      format.xml { render :layout => false }
    end
  end

  {
      talks: '专访',
      lists: '列表',
      features: '特写',
      reviews: '评测',
      specials: '专题',
      events: '活动'
  }.each do |k, v|
    class_eval <<-EVAL
        def #{k}
          @entries = Entry.published.where(category: '#{v}').desc(:created_at).page(params[:page]).per(@per)
          render 'index'
        end
    EVAL
  end

  def set_page
    params[:page] ||= 1
    @per = (params[:page].to_i > 1) ? 12 : 11
  end
end
