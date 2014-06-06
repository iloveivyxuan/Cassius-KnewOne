module Api
  module V1
    class SearchController < ApiController
      def index
        q = (params[:keyword] || '')
        q.gsub!(/[^\u4e00-\u9fa5a-zA-Z0-9[:blank:].-_]+/, '')

        render_error :missing_field, 'invalid keyword field' if q.empty?
        per = params[:per_page] || 48

        types = params[:type].try(:split, ',') || []

        if types.empty? || types.include?('things')
          @things = Thing.published.
              or({slug: /#{q}/i}, {title: /#{q}/i}, {subtitle: /#{q}/i}).
              desc(:fanciers_count).page(params[:things_page] || params[:page]).per(per)
        end

        if types.empty? || types.include?('users')
          @users = User.find_by_fuzzy(q).page(params[:users_page] || params[:page]).per(per)
        end
      end
    end
  end
end
