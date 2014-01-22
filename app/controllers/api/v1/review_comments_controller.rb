module Api
  module V1
    class ReviewCommentsController < ApiController
      before_action :set_resources
      before_action :set_review, except: :index
      doorkeeper_for :all, except: [:index, :show]

      def index
        @reviews = @review.comments.page(params[:page]).per(params[:per_page] || 8)
      end

      def show
        @comment = @review.comments.find(params[:id])
      end

      def create
        @comment = @review.comments.build(comment_params.merge(author: current_user))

        if @comment.save
          render action: 'show', status: :created, location: [:api, :v1, @thing, @review, @comment]
        else
          render json: @comment.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @review.comments.find(params[:id]).destroy
        head :no_content
      end

      private

      def comment_params
        params.require(:comment).permit(:content)
      end

      def set_resources
        @thing = Thing.find(params[:thing_id])
        @thing_group = @thing.thing_group
      end

      def set_review
        @review = @thing_group.reviews.find(params[:review_id])
      end
    end
  end
end
