module Api
  module V1
    class ExploreController < ApiController
      def features
        @entries = Entry.published.where(category: '特写').desc(:created_at).page(params[:page]).per(params[:per_page] || 8)
      end
    end
  end
end
