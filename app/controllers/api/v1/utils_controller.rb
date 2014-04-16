module Api
  module V1
    class UtilsController < ApiController
      def extract_url
        if params[:url].blank?
          render_error :missing_field, 'need url'
        end

        render text: PageExtractor.extract(params[:url]).to_json
      end
    end
  end
end
