module Api
  module V1
    class ThingsController < ApiController
      before_action :set_thing, except: [:index]

      def index
        if params[:category_id]
          c = Category.find(params[:category_id])
          scope = c.things
        else
          scope = Thing
        end

        scope = case params[:sort_by]
                    when 'fanciers_count'
                      scope.desc(:fanciers_count)
                    else
                      scope.desc(:created_at)
                  end

        scope = scope.self_run if params[:self_run].present?

        @things = scope.page(params[:page]).per(params[:per_page] || 24)
      end

      def show

      end

      private

      def set_thing
        @thing = Thing.find(params[:id])
      end
    end
  end
end
