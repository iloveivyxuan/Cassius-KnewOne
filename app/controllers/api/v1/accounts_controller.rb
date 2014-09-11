module Api
  module V1
    class AccountsController < ApiController
      doorkeeper_for :all

      def show
      end

      def feeds
        @feeds = case params[:scope]
          when "followings"
            current_user.related_activities
          when "things"
            Activity.by_types(:new_thing).visible
          when "posts"
            Activity.by_types(:new_review, :new_feeling, :new_topic).visible
          else
            Activity.by_types(:new_thing, :new_review, :new_feeling, :new_topic).visible
        end

        if params[:started_at].to_i > 0
          @feeds = @feeds.gte(created_at: params[:started_at].to_i)
        end

        if params[:ended_at].to_i > 0
          @feeds = @feeds.lte(created_at: params[:ended_at].to_i)
        end

        if params[:types].present? && types = params[:types].split(',').compact.map(&:to_sym)
          @feeds = @feeds.in(type: types)
        end

        if params[:order_by] == 'desc'
          @feeds = @feeds.desc(:created_at)
        else
          @feeds = @feeds.asc(:created_at)
        end

        @feeds = @feeds.page(params[:page]).per(params[:per_page] || 24)
      end

      def apple_device_token
        current_user.apple_device_token = params.require(:token)
        current_user.save!
        head :no_content
      end
    end
  end
end
