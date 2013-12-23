# encoding: utf-8
class DeviseMailer < Devise::Mailer
  layout 'mailer'
  default from: "no-reply@knewone.com"
  default :content_type => "text/html"
end
