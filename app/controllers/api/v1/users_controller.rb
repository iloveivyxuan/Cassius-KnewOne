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
        @reviews = @user.reviews.desc(:is_top, :lovers_count, :created_at).page(params[:page]).per(params[:per_page] || 8)
      end

      def things
        @things = @user.things.desc(:created_at).page(params[:page]).per(params[:per_page] || 8)
      end

      def owns
        @owns = @user.owns.desc(:created_at).page(params[:page]).per(params[:per_page] || 8)
      end

      def fancies
        @fancies = @user.fancies.desc(:created_at).page(params[:page]).per(params[:per_page] || 8)
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
        @activities = @user.activities.visible

        if params[:started_at].to_i > 0
          @activities = @activities.gte(created_at: params[:started_at].to_i)
        end

        if params[:ended_at].to_i > 0
          @activities = @activities.lte(created_at: params[:ended_at].to_i)
        end

        if params[:types].present? && types = params[:types].split(',').compact.map(&:to_sym)
          @activities = @activities.in(type: types)
        end

        if params[:order_by] == 'desc'
          @activities = @activities.desc(:created_at)
        else
          @activities = @activities.asc(:created_at)
        end

        @activities = @activities.page(params[:page]).per(params[:per_page] || 24)
      end

      private

      def set_user
        @user = User.find(params[:id])
      end
    end
  end
end
