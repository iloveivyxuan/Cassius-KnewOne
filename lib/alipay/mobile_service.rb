module Alipay
  module MobileService
    SDK_PAY_ORDER_REQUIRED_OPTIONS = %w( service partner _input_charset notify_url out_trade_no subject payment_type seller_id total_fee body )
    # alipayescow
    def self.sdk_pay_order_info(options)
      options = {
          'service'        => 'mobile.securitypay.pay',
          '_input_charset' => 'utf-8',
          'partner'        => Alipay.pid,
          'seller_id'   => Alipay.seller_email,
          'payment_type'   => '1'
      }.merge(Utils.stringify_keys(options))

      check_required_options(options, SDK_PAY_ORDER_REQUIRED_OPTIONS)

      query_string(options)
    end

    def self.query_string(options)
      options.merge('sign_type' => 'RSA', 'sign' => Alipay::MobileSign.generate(options)).map do |key, value|
        "#{CGI.escape(key.to_s)}=#{CGI.escape(value.to_s)}"
      end.join('&')
    end

    def self.check_required_options(options, names)
      names.each do |name|
        warn("Ailpay Warn: missing required option: #{name}") unless options.has_key?(name)
      end
    end
  end
end
