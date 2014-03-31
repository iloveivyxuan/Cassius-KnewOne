module Api
  module V1
    class UsersController < ApiController
      before_action :set_user, except: [:index]
      doorkeeper_for :all

      def index
        render_error :nyi, 'NYI'
      end

      def show
      end

      def reviews
        @reviews = @user.reviews.page(params[:page]).per(params[:per_page] || 8)
      end

      def things
        @things = @user.things.page(params[:page]).per(params[:per_page] || 8)
      end

      def owns
        @owns = @user.owns.page(params[:page]).per(params[:per_page] || 8)
      end

      def fancies
        @fancies = @user.fancies.page(params[:page]).per(params[:per_page] || 8)
      end

      def groups
        @groups = @user.joined_groups
      end

      def followers
        @followers = @user.followers.page(params[:page]).per(params[:per_page] || 24)
      end

      def followings
        @followings = @user.followings.page(params[:page]).per(params[:per_page] || 24)
      end

      def activities
        @activities = @user.activities.visible.page(params[:page]).per(24)
      end

      private

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end
