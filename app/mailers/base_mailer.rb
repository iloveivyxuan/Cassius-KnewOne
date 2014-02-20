class BaseMailer < ActionMailer::Base
  abstract!
  layout 'mailer'
  default content_type: 'text/html',
          reply_to: 'welcome@knewone.com'

  SMTP_SERVERS = {
      white: {
          from: 'welcome@knewone.com',
          delivery_settings: {
              address: 'smtp.exmail.qq.com',
              port: 25,
              domain: 'knewone.com',
              user_name: 'welcome@knewone.com',
              password: 'knewone123',
              authentication: 'plain',
              enable_starttls_auto: true
          }
      },
      default: {
          from: 'welcome@service.knewone.com',
          delivery_settings: {
              address: 'smtpcloud.sohu.com',
              port: 25,
              user_name: 'postmaster@knewone-service.sendcloud.org',
              password: 'q4yoSPmu',
              authentication: 'login',
              domain: 'sendcloud.org'
          }
      }
  }

  WHITES = %w(gmail.com ruby-china.org)

  def mail(headers = {}, &block)
    if self.delivery_method == :smtp
      smtp_config = route_smtp_server(headers[:to])
      m = super headers.merge(from: smtp_config[:from]), &block
      m.delivery_method.settings.merge!(smtp_config[:delivery_settings])
      m
    else
      super headers, &block
    end
  end

  private

  def route_smtp_server(email)
    SMTP_SERVERS[(WHITES.include?(/.*@(.+)/.match(email)[1]) ? :white : :default)]
  end
end
