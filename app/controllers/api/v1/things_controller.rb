module Api
  module V1
    class ThingsController < ApiController
      def index
        per = (params[:per] || 24).to_i

        scope = case params[:sort]
                  when "self_run"
                    Thing.self_run
                  when "fancy"
                    Thing.unscoped.published.desc(:fanciers_count)
                  when "random"
                    Thing.rand_records per
                  else
                    Thing.published
                end

        if params[:sort] == "random"
          @things = Kaminari.paginate_array(scope).page(params[:page])
        else
          @things = scope.page(params[:page]).per(per)
        end
      end

      def show

      end
    end
  end
end
