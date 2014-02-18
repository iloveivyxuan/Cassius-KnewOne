class BaseMailer < ActionMailer::Base
  abstract!
  layout 'mailer'
  default from: 'welcome@knewone.com',
          content_type: 'text/html',
          reply_to: 'welcome@knewone.com'

  SMTP_SERVERS = {
      white: {
          address: 'smtp.exmail.qq.com',
          port: 25,
          domain: 'knewone.com',
          user_name: 'welcome@knewone.com',
          password: 'knewone123',
          authentication: 'plain',
          enable_starttls_auto: true
      },
      default: {
          address: 'smtp.exmail.qq.com',
          port: 25,
          domain: 'knewone.com',
          user_name: 'welcome@knewone.com',
          password: 'knewone123',
          authentication: 'plain',
          enable_starttls_auto: true
      }
  }

  WHITES = %w(gmail.com)

  def mail(headers = {}, &block)
    m = super headers, &block
    m.delivery_method.settings.merge!(route_smtp_server(m.to.first)) if self.delivery_method == :smtp
    m
  end

  private

  def route_smtp_server(email)
    SMTP_SERVERS[(WHITES.include?(/.*@(.+)/.match(email)[1]) ? :white : :default)]
  end
end
