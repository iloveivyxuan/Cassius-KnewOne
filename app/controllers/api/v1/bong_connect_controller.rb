require 'digest/md5'

module Api
  module V1
    class BongConnectController < ApiController
      before_action :check_fields, :check_expired, :check_sign, :set_user

      skip_after_action :respond_request

      APP_ID = '5412c5bb31302d6308070000'
      SECRET = 'f52105d6'

      def create
        unless @user.auths.where(provider: 'bong').exists?
          @user.auths.create uid: params[:uid], provider: 'bong', name: params[:name]
        end

        app = Doorkeeper::Application.find('5412c5bb31302d6308070000')

        token = app.access_tokens.where(resource_owner_id: @user.id).first
        unless token
          token = app.access_tokens.create! resource_owner_id: @user.id,
                                            scopes: 'public',
                                            expires_in: Doorkeeper.configuration.access_token_expires_in,
                                            use_refresh_token: Doorkeeper.configuration.refresh_token_enabled?
        end

        render :json => {:access_token => token.token, :uid => @user.id.to_s}
      end

      private

      def check_fields
        unless [:name, :uid, :email, :password, :timestamp, :sign].map { |i| params[i].present? }.reduce &:&
          render :status => :not_acceptable, :json => {:message => 'field missing'}
        end
      end

      def check_expired
        if params[:timestamp].to_i < Time.now.to_i - 300
          render :status => :request_timeout, :json => {:message => 'expired'}
        end
      end

      def check_sign
        if params[:sign].blank? || !valid_sign?(params.except(*request.path_parameters.keys))
          render :status => :bad_request, :json => {:message => 'invalid sign'}
        end
      end

      def set_user
        @user = User.where(email: params[:email]).first
        if @user
          unless @user.valid_password?(params[:password])
            render :status => :unauthorized, :json => {:message => 'invalid password'}
          end
        else
          @user = User.create name: "#{params[:name]}@bong", password: params[:password], email: params[:email]
        end
      end

      def generate(params)
        timestamp = params.delete 'timestamp'

        query = params.sort.push(['timestamp', timestamp]).map do |key, value|
          "#{key}=#{value}"
        end.join('&')

        Digest::MD5.hexdigest("#{query}#{SECRET}")
      end

      def valid_sign?(params)
        params = params.stringify_keys
        sign = params.delete('sign')

        Digest::MD5.hexdigest(generate(params)) == Digest::MD5.hexdigest(sign)
      end
    end
  end
end
