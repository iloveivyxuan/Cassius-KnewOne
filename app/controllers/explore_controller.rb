class ExploreController < ApplicationController
  skip_before_action :require_not_blocked
  helper :entries

  def index
    params[:page] ||= 1
    per = (params[:page].to_i > 1) ? 8 : 7
    @entries = Entry.published.ne(category: '活动').desc(:created_at).page(params[:page]).per(per)

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
          @entries = Entry.published.where(category: '#{v}').desc(:created_at).page(params[:page]).per(6)
          render 'index'
        end
    EVAL
  end
end
