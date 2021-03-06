require 'digest/md5'

module Api
  module V1
    class OauthController < ApiController
      before_action :check_fields, :check_expired, :check_sign, :check_provider, only: :exchange_access_token

      skip_after_action :respond_request
      APP_NAME = 'KnewOne APP'
      SECRET = '62b5f1b6'

      WEIBO_APPKEY = '1934398743'
      WEIBO_SECRET = '39084336b9ac5f3ae48535e31b737821'

      TWITTER_APPKEY = 'BvmzfKWOgpaSin9UldEybFRNQ'
      TWITTER_SECRET = 'flAI84stBSsoP4v9xr4iMfDOYvOLZ9SWXvxatNkgNh3DG9UDXV'

      def exchange_access_token
        begin
          profile = send :"get_profile_from_#{params[:provider]}"
        rescue OAuth2::Error
          return render :status => :bad_request, :json => {:message => "fetch profile from #{params[:provider]} failure"}
        end

        user = User.find_by_omniauth(provider: params[:provider], uid: profile[:id])
        unless user
          user = User.create_from_mobile_app(params[:provider], profile)
        end

        app = Doorkeeper::Application.where(name: APP_NAME).first

        token = app.access_tokens.where(resource_owner_id: user.id).first
        unless token
          token = app.access_tokens.create! resource_owner_id: user.id,
                                            scopes: 'public official',
                                            expires_in: Doorkeeper.configuration.access_token_expires_in,
                                            use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
        end

        render :json => {:access_token => token.token, :user_id => user.id.to_s}
      end

      def default_callback
        if params[:code].blank?
          head :not_acceptable
        else
          render json: {type: 'authorization_code', code: params[:code]}
        end
      end

      def default_callback_2
        render json: params.except(*request.path_parameters.keys)
      end

      private

      def check_fields
        if params[:provider].blank? || params[:access_token].blank? || params[:timestamp].blank? || params[:sign].blank?
          render :status => :not_acceptable, :json => {:message => 'field missing'}
        end
      end

      def check_expired
        if params[:timestamp].to_i < Time.now.to_i - 300
          render :status => :request_timeout, :json => {:message => 'expired'}
        end
      end

      def check_sign
        sign = Digest::MD5.hexdigest(params[:provider] + params[:access_token] + params[:timestamp] + SECRET)
        if Digest::MD5.hexdigest(sign) != Digest::MD5.hexdigest(params[:sign])
          render :status => :bad_request, :json => {:message => 'invalid sign'}
        end
      end

      def check_provider
        unless %w(weibo twitter).include?(params[:provider])
          render :status => :bad_request, :json => {:message => 'invalid provider'}
        end
      end

      def get_profile_from_weibo
        client = WeiboOAuth2::Client.new(WEIBO_APPKEY, WEIBO_SECRET)
        client.get_token_from_hash :access_token => params[:access_token]

        result = client.oauth2.get_token_info

        if result.appkey.to_s != WEIBO_APPKEY
          return render :status => :bad_request, :json => {:message => 'invalid access token'}
        end

        uid = result.uid.to_s

        if uid.blank?
          return render :status => :bad_request, :json => {:message => 'invalid access_token'}
        end

        client.users.show(uid: uid)
      end

      def get_profile_from_twitter
        client = Twitter::REST::Client.new do |config|
          config.access_token = params[:access_token]
          config.access_token_secret = params[:access_secret]
          config.consumer_key = TWITTER_APPKEY
          config.consumer_secret = TWITTER_SECRET
        end
        client.current_user
      end
    end
  end
end
