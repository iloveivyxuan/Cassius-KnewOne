module Api
  module V1
    class ThingCommentsController < ApiController
      before_action :set_resources
      doorkeeper_for :all, except: [:index, :show]

      def index
        @comments = @thing.comments.page(params[:page]).per(params[:per_page] || 8)
      end

      def show
        @comment = @thing.comments.find(params[:id])
      end

      def create
        @comment = @thing.comments.build(comment_params.merge(author: current_user))

        if @comment.save
          render action: 'show', status: :created, location: [:api, :v1, @thing, @comment]
        else
          render json: @comment.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @thing.comments.find(params[:id]).destroy
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
    end
  end
end
