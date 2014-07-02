require 'openssl'

Alipay.pid = '2088901758538631'
Alipay.key = '9hogekkasdnitonn3j8vn3jwhvih7y50'
Alipay.seller_email = 'hello@knewone.com'

Alipay::MobileSign.private_key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('lib/alipay/rsa_private_key.pem')))
Alipay::MobileSign.alipay_public_key = OpenSSL::PKey::RSA.new(File.read(Rails.root.join('lib/alipay/alipay_public_key.pem')))
