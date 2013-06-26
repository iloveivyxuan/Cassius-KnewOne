class BaseMailer < ActionMailer::Base
  abstract!
  layout 'mailer'
  default from: "no-reply@knewone.com"
  default :content_type => "text/html"
end
