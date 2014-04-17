module Api
  module V1
    class UtilsController < ApiController
      def extract_url
        if params[:url].blank?
          render_error :missing_field, 'need url'
        end

        render text: PageExtractor.extract(params[:url]).to_json
      end

      def find_similar
        if params[:keyword].blank?
          render_error :missing_field, 'need keyword'
        end

        @thing = Thing.unscoped.published.or({slug: /#{params[:keyword]}/i},
                                             {title: /#{params[:keyword]}/i},
                                             {subtitle: /#{params[:keyword]}/i}).desc(:fanciers_count).first

        if @thing
          render text: {
              title: @thing.title,
              url: thing_url(@thing),
              cover_url: @thing.cover.url(:normal)
          }.to_json
        else
          head :no_content
        end
      end
    end
  end
end
