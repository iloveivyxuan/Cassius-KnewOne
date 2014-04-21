module Api
  module V1
    class AccountsController < ApiController
      doorkeeper_for :all

      def show
      end

      def feeds
        @feeds = current_user.relate_activities.visible

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
    end
  end
end
