module Api
  module V1
    class ThingsController < ApiController
      before_action :set_thing, except: [:index]

      def index
        if c_id = (params[:category_id] || params[:category])
          c = Category.find(c_id)
          scope = c.things.unscoped.published
        else
          scope = Thing.unscoped.published
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
