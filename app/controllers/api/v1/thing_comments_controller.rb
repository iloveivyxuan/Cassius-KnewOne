module Api
  module V1
    class ThingCommentsController < ApiController
      before_action :set_resources
      before_action :set_comment, only: [:show, :destroy]
      before_action :check_authorization, only: [:destroy]
      doorkeeper_for :all, except: [:index, :show]

      def index
        @comments = @thing.comments.page(params[:page]).per(params[:per_page] || 8)
      end

      def show

      end

      def create
        @comment = @thing.comments.build(comment_params.merge(author: current_user))

        if @comment.save
          @comment.author.log_activity :comment, @comment.post, check_recent: true
          render action: 'show', status: :created, location: [:api, :v1, @thing, @comment]
        else
          render json: @comment.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @comment.destroy
        head :no_content
      end

      private

      def comment_params
        params.require(:comment).permit(:content)
      end

      def set_resources
        @thing = Thing.find(params[:thing_id])
      end

      def set_comment
        @comment = @thing.comments.find(params[:id])
      end

      def check_authorization
        head :unauthorized unless @comment.author == current_user
      end
    end
  end
end
