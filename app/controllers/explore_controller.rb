#encoding: utf-8
class ExploreController < ApplicationController
  def index
    @entries = Entry.published.desc(:created_at).page(params[:page]).per(6)

    respond_to do |format|
      format.html
      format.atom
    end
  end

  {
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
