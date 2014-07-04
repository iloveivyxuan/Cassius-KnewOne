module Api
  module V1
    class FeelingsController < ApiController
      before_action :set_resources
      before_action :set_feeling, only: [:show]

      def index
        @feelings = @thing.feelings.desc(:lovers_count, :created_at).page(params[:page]).per(params[:per_page] || 8)
      end

      def show
      end

      def create
        photos = []
        if params[:images]
          photos = params[:images].map do |image|
            Photo.create! image: image, user: current_user
          end
        end

        @feeling = @thing.feelings.build feeling_params
        @feeling.author = current_user
        @feeling.photo_ids.concat photos.map { |p| p.id.to_s }

        if @feeling.save
          render action: 'show', status: :created, location: [:api, :v1, @thing, @feeling]
        else
          render json: @feeling.errors, status: :unprocessable_entity
        end
      end

      private

      def set_resources
        @thing = Thing.find(params[:thing_id])
      end

      def set_feeling
        @feeling = @thing.feelings.find(params[:id])
      end

      def feeling_params
        params.require(:feeling).permit :content, :score
      end
    end
  end
end
