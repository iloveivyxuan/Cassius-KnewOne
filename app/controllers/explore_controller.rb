#encoding: utf-8
class ExploreController < ApplicationController
  def index
    @entries = Entry.published.page params[:page]
  end

  {
      features: '特写',
      reviews: '评测',
      specials: '专题',
      events: '活动'
  }.each do |k, v|
    class_eval <<-EVAL
        def #{k}
          @entries = Entry.published.where(category: '#{v}').page params[:page]
          render 'index'
        end
    EVAL
  end
end
