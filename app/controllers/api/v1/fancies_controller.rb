module Api
  module V1
    class FanciesController < ApiController
      doorkeeper_for :all

      def show
        if current_user.fancies.where(id: params[:id]).exists?
          head :no_content
        else
          head :not_found
        end
      end

      def update
        Thing.find(params[:id]).fancy(current_user)
        head :no_content
      end

      def destroy
        Thing.find(params[:id]).unfancy(current_user)
        head :no_content
      end
    end
  end
end
