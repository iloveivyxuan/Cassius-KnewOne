module Api
  module V1
    class ThingsController < ApiController
      helper 'api/v1/things'

      def index
        per_page = (params[:per_page] || 8).to_i

        scope = Thing
        scope = scope.send params[:scope].to_sym if params[:scope].present?
        scope = scope.where(title: /^#{params[:keyword]}/i) if params[:keyword].present?
        if params[:sort_by].blank?
          scope = scope.prior
        end

        @things = scope.page(params[:page]).per(per_page)
      end

      def show
        @thing = Thing.find(params[:id])
      end
    end
  end
end
