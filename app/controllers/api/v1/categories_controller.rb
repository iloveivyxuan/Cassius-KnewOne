module Api
  module V1
    class CategoriesController < ApiController
      def index
        @categories = Category.gt(things_count: 10).page(params[:page]).per(params[:per_page] || 24)
      end

      def show
        @category = Category.find(params[:id])
      end
    end
  end
end
