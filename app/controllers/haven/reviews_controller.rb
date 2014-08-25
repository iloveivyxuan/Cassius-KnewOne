module Haven
  class ReviewsController < Haven::ApplicationController
    layout 'settings'

    def index
      @reviews = Review.desc(:created_at)

      if params[:from].present?
        @reviews = @reviews.where(:created_at.gte => Date.parse(params[:from]))
      end
      if params[:to].present?
        @reviews = @reviews.where(:created_at.lt => Date.parse(params[:to]).next_day)
      end

      @reviews = @reviews.page params[:page]
    end
  end
end
