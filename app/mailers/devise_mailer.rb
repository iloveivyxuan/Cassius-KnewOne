# encoding: utf-8
class DeviseMailer < Devise::Mailer
  layout 'mailer'
  default from: 'lilu@knewone.com',
          content_type: 'text/html',
          reply_to: 'hello@knewone.com'
end
