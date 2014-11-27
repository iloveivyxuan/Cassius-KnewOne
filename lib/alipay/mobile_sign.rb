require 'base64'
require 'openssl'

module Alipay
  module MobileSign
    mattr_accessor :private_key, :alipay_public_key

    def self.to_query_string(params, wrap_quotation = true)
      params.sort.map do |key, value|
        wrap_quotation ? "#{key.to_s}=\"#{value.to_s.gsub('"', '')}\"" : "#{key.to_s}=#{value.to_s.gsub('"', '')}"
      end.join('&')
    end

    def self.generate(params, wrap_quotation = true)
      Base64.encode64(private_key.sign(OpenSSL::Digest::SHA1.new, to_query_string(params, wrap_quotation))).gsub("\n", '')
    end

    def self.verify?(params)
      params = ::Alipay::Utils.stringify_keys(params)
      params.delete('sign_type')
      sign = params.delete('sign')

      alipay_public_key.verify(OpenSSL::Digest::SHA1.new, Base64.decode64(sign), to_query_string(params, false))
    end
  end
end
