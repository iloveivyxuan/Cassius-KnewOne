#encoding: utf-8
require 'digest/md5'

module Api
  module V1
    class OauthController < ApiController
      skip_after_action :respond_request
      APP_NAME = 'KnewOne APP'
      SECRET = '62b5f1b6'

      def exchange_access_token
        if params[:provider].blank? || params[:access_token].blank? || params[:timestamp].blank? || params[:sign].blank?
          return render :status => :not_acceptable, :json => {:message => 'field missing'}
        end

        if params[:timestamp].to_i < Time.now.to_i - 300
          return render :status => :request_timeout, :json => {:message => 'expired'}
        end

        if Digest::MD5.hexdigest(params[:provider] + params[:access_token] + params[:timestamp] + SECRET) != params[:sign]
          return render :status => :bad_request, :json => {:message => 'invalid sign'}
        end

        case params[:provider]
          when 'weibo'
            client = WeiboOAuth2::Client.new(Settings.weibo.consumer_key, Settings.weibo.consumer_secret)
            client.get_token_from_hash :access_token => params[:access_token]
            uid = client.account.get_uid.uid.to_s
          when 'twitter'
            client = Twitter::REST::Client.new access_token: info[:access_token],
                                               access_token_secret: info[:access_secret],
                                               consumer_key: Settings.twitter.consumer_key,
                                               consumer_secret: Settings.twitter.consumer_secret
            result = client.users.verify_credentials
            uid = result[:id_str]
          else
            return render :status => :bad_request, :json => {:message => 'invalid provider'}
        end

        if uid.blank?
          return render :status => :bad_request, :json => {:message => 'invalid access_token'}
        end

        user = User.find_by_omniauth(provider: params[:provider], uid: uid)
        unless user
          user = User.create_from_mobile_app(params[:provider], uid)
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
    end
  end
end
