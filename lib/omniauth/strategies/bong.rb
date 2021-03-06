require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Bong < OmniAuth::Strategies::OAuth2
      if Rails.env.production?
        HOST = 'https://open.bong.cn/'
      else
        HOST = 'http://open-test.bong.cn/'
      end
      option :client_options, {
        :site => HOST,
        :authorize_url => "/oauth/authorize",
        :token_url => "/oauth/token"
      }

      option :token_params, {
        :parse => :json
      }

      uid do
        access_token['uid']
      end

      info do
        {
          :name => raw_info['name'],
          :gender => raw_info['gender'],
          :birthday => raw_info['birthday'],
          :weight => raw_info['weight'],
          :height => raw_info['height'],
          :target_sleep_time => raw_info['targetSleepTime'],
          :target_calorie => raw_info['targetCalorie']
        }
      end

      extra do
        {
          :raw_info => raw_info
        }
      end

      def raw_info
        access_token.options[:mode] = :query
        access_token.options[:param_name] = 'access_token'
        @uid ||= access_token['uid']
        # @raw_info ||= access_token.get("/1/userInfo/#{@uid}").parsed['value'] || {}

        # API 处理过慢
        @raw_info ||= {
          :name => "b#{access_token.token[0..6]}"
        }
      end

      def authorize_params
        super.tap do |params|
          if request.params['state']
            params[:state] = request.params['state']

            # to support omniauth-oauth2's auto csrf protection
            session['omniauth.state'] = params[:state]
          end
        end
      end
    end
  end
end

OmniAuth.config.add_camelization "bong", "Bong"
