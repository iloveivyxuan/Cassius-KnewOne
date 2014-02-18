class BaseMailer < ActionMailer::Base
  abstract!
  layout 'mailer'
  default from: 'welcome@knewone.com',
          content_type: 'text/html',
          reply_to: 'welcome@knewone.com'
end
