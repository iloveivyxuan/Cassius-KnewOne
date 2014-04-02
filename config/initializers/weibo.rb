WeiboOAuth2::Config.api_key = Settings.weibo.consumer_key
WeiboOAuth2::Config.api_secret = Settings.weibo.consumer_secret

module WeiboOAuth2
  module Api
    module V2
      class Oauth2 < Base
        def get_token_info
          hashie post("oauth2/get_token_info", params: {access_token: @access_token.token})
        end
      end
    end
  end
end

module WeiboOAuth2
  class Client < OAuth2::Client
    def oauth2
      @oauth2 ||= WeiboOAuth2::Api::V2::Oauth2.new(@access_token) if @access_token
    end
  end
end
