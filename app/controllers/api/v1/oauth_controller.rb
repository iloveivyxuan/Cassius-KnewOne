#encoding: utf-8
require 'digest/md5'

module Api
  module V1
    class OauthController < ApiController
      before_action :check_fields, :check_expired, :check_sign, :check_provider, only: :exchange_access_token

      skip_after_action :respond_request
      APP_NAME = 'KnewOne APP'
      SECRET = '62b5f1b6'

      WEIBO_APPKEY = '1934398743'
      WEIBO_APPSECRET = '39084336b9ac5f3ae48535e31b737821'

      def exchange_access_token
        profile = send :"get_profile_from_#{params[:provider]}"

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
        if Digest::MD5.hexdigest(params[:provider] + params[:access_token] + params[:timestamp] + SECRET) != params[:sign]
          render :status => :bad_request, :json => {:message => 'invalid sign'}
        end
      end

      def check_provider
        unless %w(weibo twitter).include?(params[:provider])
          render :status => :bad_request, :json => {:message => 'invalid provider'}
        end
      end

      def get_profile_from_weibo
        client = WeiboOAuth2::Client.new(WEIBO_APPKEY, WEIBO_APPSECRET)
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
        #TODO: May consider access_token belongs_to consumer, but seems no api can do this, or no need?
        client = Twitter::REST::Client.new access_token: params[:access_token],
                                           access_token_secret: params[:access_secret],
                                           consumer_key: Settings.twitter.consumer_key,
                                           consumer_secret: Settings.twitter.consumer_secret
        client.users.verify_credentials
      end
    end
  end
end
