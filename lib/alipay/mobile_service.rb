module Alipay
  module MobileService
    GATEWAY_URL = 'https://mapi.alipay.com/gateway.do'

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

    SECURITY_RISK_DETECT_REQUIRED_OPTIONS = %w(order_no order_credate_time order_category order_item_name order_amount buyer_account_no buyer_reg_date)
    def self.security_risk_detect(options)
      options = {
        'service'        => 'alipay.security.risk.detect',
        '_input_charset' => 'utf-8',
        'partner'        => Alipay.pid,
        'timestamp'   => Time.now.strftime('%Y-%m-%d %H:%M:%S'),
        'terminal_type' => 'WEB',
        'scene_code'   => 'PAYMENT'
      }.merge(Utils.stringify_keys(options))

      options['order_category'] = options['order_category']
      options['order_item_name'] = options['order_item_name']

      check_required_options(options, SECURITY_RISK_DETECT_REQUIRED_OPTIONS)

      RestClient.post GATEWAY_URL, options.merge('sign_type' => 'RSA', 'sign' => Alipay::MobileSign.generate(options, false))
    end

    def self.query_string(options)
      options['subject'] = CGI.escape(options['subject'])
      options['body'] = CGI.escape(options['body'])
      options.sort.concat([['sign_type', 'RSA'], ['sign', CGI.escape(Alipay::MobileSign.generate(options))]]).map do |key, value|
        "#{key}=\"#{value}\""
      end.join('&')
    end

    def self.check_required_options(options, names)
      names.each do |name|
        warn("Ailpay Warn: missing required option: #{name}") unless options.has_key?(name)
      end
    end
  end
end
