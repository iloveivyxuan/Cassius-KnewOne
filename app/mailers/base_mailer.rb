class BaseMailer < ActionMailer::Base
  abstract!
  layout 'mailer'
  default from: 'lilu@knewone.com',
          content_type: 'text/html',
end
