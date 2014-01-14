module Api
  module V1
    class CommentsController < ApiController
      before_action :set_resources

      def index
        @comments = @thing.comments.page(params[:page]).per(params[:per_page] || 8)
      end

      private

      def set_resources
        @thing = Thing.find(params[:thing_id])
        @thing_group = @thing.thing_group
      end
    end
  end
end
