module Api
  module V1
    class FriendsController < ApiController
      doorkeeper_for :all

      def recommends
        @recommends = User.desc(:recommend_priority, :followers_count).limit(42)
      end

      def weibo
        @friends = current_user.recommend_users || []
      end

      def batch_follow
        users = User.where :id.in => params[:ids]

        current_user.batch_follow users

        head :no_content
      end
    end
  end
end
