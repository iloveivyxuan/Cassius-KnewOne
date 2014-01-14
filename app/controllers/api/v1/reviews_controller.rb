module Api
  module V1
    class ReviewsController < ApiController
      helper 'api/v1/reviews'
      before_action :set_resources

      def index
        @reviews = @thing_group.reviews.page(params[:page]).per(params[:per_page] || 8)
      end

      def show
        @review = current_review
      end

      private

      def set_resources
        @thing = Thing.find(params[:thing_id])
        @thing_group = @thing.thing_group
      end

      def current_review
        @thing_group.reviews.find(params[:id])
      end
    end
  end
end
