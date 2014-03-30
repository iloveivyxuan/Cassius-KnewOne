module Api
  module V1
    class FollowingsController < ApiController
      doorkeeper_for :all

      def show
        if current_user.followings.where(id: params[:id]).exists?
          head :no_content
        else
          head :not_found
        end
      end

      def update
        current_user.follow User.find(params[:id])
        head :no_content
      end

      def destroy
        current_user.unfollow User.find(params[:id])
        head :no_content
      end
    end
  end
end
