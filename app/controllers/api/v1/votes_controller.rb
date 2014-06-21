module Api
  module V1
    class VotesController < ApiController
      doorkeeper_for :all
      before_action :set_post

      def create
        @post.vote(current_user, true)
        head :no_content
      end

      def destroy
        @post.unvote(current_user, true)
        head :no_content
      end

      def show
        if @post.lovers.include? current_user
          head :no_content
        else
          head :not_found
        end
      end

      private

      def set_post
        @post = Post.or({id: params.values.last}, {_slugs: params.values.last}).first
        head(:not_found) unless @post
      end
    end
  end
end
