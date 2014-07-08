module Alipay
  class Notify
    def self.verify?(params)
      params = Utils.stringify_keys(params)

      sign_verified = case params['sign_type'].downcase
                        when 'md5'
                          Sign.verify?(params)
                        when 'rsa'
                          MobileSign.verify?(params)
                        else
                          false
                      end

      sign_verified &&
          (open("https://mapi.alipay.com/gateway.do?service=notify_verify&partner=#{Alipay.pid}&notify_id=#{CGI.escape params['notify_id'].to_s}").read == 'true')
    end
  end
end
