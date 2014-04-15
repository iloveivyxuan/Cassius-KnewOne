# -*- coding: utf-8 -*-
module Hell
  class ApplicationController < ::ActionController::Base
    SECRET = 'd15cd239'
    prepend_before_action :check_expired
    prepend_before_action :check_sign

    private

    def check_expired
      if params[:timestamp].to_i < Time.now.to_i - 300
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def check_sign
      if params[:sign].blank? || !valid_sign?(params.except(*request.path_parameters.keys))
        raise ActionController::RoutingError.new('Not Found')
      end
    end

    def generate(params)
      timestamp = params.delete 'timestamp'

      query = params.sort.map do |key, value|
        "#{key}=#{value}"
      end.join('&')

      if query.blank?
        Digest::MD5.hexdigest("timestamp=#{timestamp}#{SECRET}")
      else
        Digest::MD5.hexdigest("#{query}&timestamp=#{timestamp}#{SECRET}")
      end
    end

    def valid_sign?(params)
      params = params.stringify_keys
      sign = params.delete('sign')

      generate(params) == sign
    end
  end
end
