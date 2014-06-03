class BaseMailer < ActionMailer::Base
  abstract!
  layout 'mailer'
  default content_type: 'text/html',
          reply_to: 'help@knewone.com'

  SMTP_SERVERS = {
      white: {
          from: 'KnewOne <welcome@mg.knewone.com>',
          delivery_settings: {
              address: 'smtp.mailgun.org',
              port: 25,
              domain: 'knewone.com',
              user_name: 'postmaster@mg.knewone.com',
              password: '2i7eb7yyb7k0',
              authentication: 'plain',
              enable_starttls_auto: true
          }
      },
      default: {
          from: 'KnewOne <welcome@service.knewone.com>',
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
    attachments.inline['logo.png'] = File.read(Rails.root.join("app/assets/images/logos/#{rand(21)+1}.png"))

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
