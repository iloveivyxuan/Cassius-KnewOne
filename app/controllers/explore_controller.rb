class ExploreController < ApplicationController
  skip_before_action :require_not_blocked
  helper :entries
  before_action :set_params

  def index
    entries = Entry.published.not.in(category: %w(活动 特写))
    @entries = entries.desc(:created_at).page(@page).per(@per).offset(@offset)
    @pager = Kaminari.paginate_array([], total_count: entries.size).page(params[:page]).per(12)

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
          @entries = Entry.published.where(category: '#{v}').desc(:created_at).page(@page).per(@per).offset(@offset)
          render 'index'
        end
    EVAL
  end

  def set_params
    default_per = 12
    n = (params[:page].to_i > 0) ? params[:page].to_i : 1 # WTF..`nil.to_i == 0` ???????

    @page   = n
    @per    = (n == 1) ? default_per - 1 : default_per
    @offset = (n == 1) ? 0 : default_per * (n - 1) - 1
  end
end
