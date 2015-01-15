module Api
  module V1
    class OwnsController < ApiController
      doorkeeper_for :all

      def show
        if current_user.owns.where(id: params[:id]).exists?
          head :no_content
        else
          head :not_found
        end
      end

      def update
        thing = Thing.find(params[:id])
        thing.own(current_user)

        head :no_content
      end

      def destroy
        Thing.find(params[:id]).unown(current_user)
        head :no_content
      end
    end
  end
end
