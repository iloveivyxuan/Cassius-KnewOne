if true# !Rails.env.development?
  Making::Application.configure do
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.perform_deliveries = true
    config.action_mailer.raise_delivery_errors = true
    config.action_mailer.default_url_options = { :host => Settings.host }
  end

  Dkim::domain      = 'service.knewone.com'
  Dkim::selector    = 'mail'
  Dkim::private_key = File.read(Rails.root.join('lib/sendcloud.pem'))

  require 'mailer_interceptor'
  ActionMailer::Base.register_interceptor(MailerInterceptor)
else
  Making::Application.configure do
    config.action_mailer.delivery_method = :letter_opener

    config.action_mailer.default_url_options = { :host => Settings.host }
  end
end
