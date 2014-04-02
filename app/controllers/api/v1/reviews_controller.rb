module Api
  module V1
    class ReviewsController < ApiController
      before_action :set_resources
      before_action :set_review, only: [:show]

      def index
        @reviews = @thing.reviews.page(params[:page]).per(params[:per_page] || 8)
      end

      def show
      end

      private

      def set_resources
        @thing = Thing.find(params[:thing_id])
      end

      def set_review
        @review = @thing.reviews.find(params[:id])
      end
    end
  end
end
