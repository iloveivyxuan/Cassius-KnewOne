module Api
  module V1
    class UsersController < ApiController
      before_action :set_user, except: [:index, :create, :password]
      doorkeeper_for :all, except: [:create, :password]
      APP_NAME = 'KnewOne APP'

      def index
        render_error :nyi, 'NYI'
      end

      def create
        params[:password_confirmation] = params[:password] # no need password confirmation when sign up

        user = User.new user_params

        if user.save
          app = Doorkeeper::Application.where(name: APP_NAME).first
          token = app.access_tokens.create! resource_owner_id: user.id,
                                            scopes: 'public official',
                                            expires_in: Doorkeeper.configuration.access_token_expires_in,
                                            use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
          render :json => { :access_token => token.token, :user_id => user.id.to_s }
        else
          render json: user.errors, status: :unprocessable_entity
        end
      end

      def password
        if User.send_reset_password_instructions(user_params)
          head :no_content
        else
          head :not_found
        end
      end

      def show
      end

      def reviews
        @reviews = @user.reviews.desc(:is_top, :lovers_count, :created_at).page(params[:page]).per(params[:per_page] || 8)
      end

      def feelings
        @feelings = @user.feelings.desc(:created_at).page(params[:page]).per(params[:per_page] || 24)
      end

      def things
        @things = @user.things.desc(:created_at).page(params[:page]).per(params[:per_page] || 8)
      end

      def owns
        @owns = @user.owns_sorted_by_ids(params[:page], params[:per_page] || 8)
      end

      def fancies
        @fancies = @user.fancies_sorted_by_ids(params[:page], params[:per_page] || 8)
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

      def user_params
        params.require(:user).permit :name, :email, :password, :avatar
      end
    end
  end
end
