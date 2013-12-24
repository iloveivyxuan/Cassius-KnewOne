# encoding: utf-8
class DeviseMailer < Devise::Mailer
  layout 'mailer'
  default from: 'lilu@knewone.com',
          content_type: 'text/html'
end
