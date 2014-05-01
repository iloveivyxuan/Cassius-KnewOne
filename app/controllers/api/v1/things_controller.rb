module Api
  module V1
    class ThingsController < ApiController
      doorkeeper_for [:create]
      before_action :set_thing, except: [:index, :create]

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

      def create
        render_error :missing_field, 'missing images' unless params[:images] || params[:images].empty?

        photo_ids = params[:images].map do |image|
          Photo.create! image: image, user: current_user
        end.map {|p| p.id.to_s}

        @thing = Thing.new thing_params.merge(author: current_user, photo_ids: photo_ids)

        if @thing.save!
          render 'show', status: :created, location: [:api, :v1, @thing]
        else
          render json: @thing.errors, status: :unprocessable_entity
        end
      end

      private

      def set_thing
        @thing = Thing.find(params[:id])
      end

      def thing_params
        params.require(:thing)
        .permit(:title, :subtitle, :official_site,
                :content, :description, photo_ids: [])
      end
    end
  end
end
