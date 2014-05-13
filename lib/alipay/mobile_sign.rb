require 'base64'
require 'openssl'

module Alipay
  module MobileSign
    mattr_accessor :private_key, :alipay_public_key

    def self.to_query_string(params)
      params.sort.map do |key, value|
        "#{key}=#{value}"
      end.join('&')
    end

    def self.generate(params)
      Base64.encode64 private_key.sign(OpenSSL::Digest::SHA256.new, to_query_string(params))
    end

    def self.verify?(params)
      params = ::Alipay::Utils.stringify_keys(params)
      params.delete('sign_type')
      sign = params.delete('sign')

      alipay_public_key.verify(OpenSSL::Digest::SHA256.new, Base64.decode64(sign), to_query_string(params))
    end
  end
end
