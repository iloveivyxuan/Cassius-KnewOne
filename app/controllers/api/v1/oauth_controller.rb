module Api
  module V1
    class OauthController < ApiController
      skip_after_action :respond_request

      def default_callback
        if params[:code].blank?
          head :not_acceptable
        else
          render json: {type: 'authorization_code', code: params[:code]}
        end
      end
    end
  end
end
