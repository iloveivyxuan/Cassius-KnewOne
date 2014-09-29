require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Bong < OmniAuth::Strategies::OAuth2
      option :client_options, {
        :site => "https://open.bong.cn/",
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
        @raw_info ||= access_token.get("/1/userInfo/#{@uid}").parsed['value'] || {}
      end
    end
  end
end

OmniAuth.config.add_camelization "bong", "Bong"
