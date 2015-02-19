require 'mail/dkim_field'
class MailerInterceptor
  def self.delivering_email(message)
    # 这里会出现邮箱为`123@qq. com`或者`123@qq.com\n`的情况
    message['to'].gsub!(' ', '')
    message['to'].gsub!("\n", '')
    message['to'].gsub!('..', '')

    method = EXCEPTIONAL[(/.*@(.+)/.match(message['to'].to_s)[1])] || :sendcloud

    smtp_config = if message['edm']
                    message['edm'] = nil
                    EDM_SMTP_SERVERS[method]
                  else
                    SMTP_SERVERS[method]
                  end

    message['from'] = smtp_config[:from]
    message.delivery_method.settings.merge!(smtp_config[:delivery_settings])

    if method == :sendcloud
      # strip any existing signatures
      if message['DKIM-Signature']
        warn "WARNING: Dkim::Interceptor given a message with an existing signature, which it has replaced."
        warn "If you really want to add a second signature to the message, you should be using the dkim gem directly."
        message['DKIM-Signature'] = nil
      end

      # generate new signature
      dkim_signature = ::Dkim::SignedMail.new(message.encoded).dkim_header.value

      # prepend signature to message
      message.header.fields.unshift ::Mail::DkimField.new(dkim_signature)
    end

    message
  end

  SMTP_SERVERS = {
    mailgun: {
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
    sendcloud: {
      from: 'KnewOne <welcome@service.knewone.com>',
      delivery_settings: {
        address: 'smtpcloud.sohu.com',
        port: 25,
        user_name: 'postmaster@notify.service.knewone.com',
        password: 'ckfsuXRzZugsoHib',
        authentication: 'login',
        domain: 'sendcloud.org'
      }
    },
    sendcloud_fallback: {
      from: 'KnewOne <welcome@service.knewone.com>',
      delivery_settings: {
        address: 'smtpcloud.sohu.com',
        port: 25,
        user_name: 'postmaster@knewone-service.sendcloud.org',
        password: 'ckfsuXRzZugsoHib',
        authentication: 'login',
        domain: 'sendcloud.org'
      }
    }
  }

  EDM_SMTP_SERVERS = {
    mailgun: {
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
    sendcloud: {
      from: 'KnewOne <welcome@service.knewone.com>',
      delivery_settings: {
        address: 'smtpcloud.sohu.com',
        port: 25,
        user_name: 'postmaster@info.service.knewone.com',
        password: 'ckfsuXRzZugsoHib',
        authentication: 'login',
        domain: 'sendcloud.org'
      }
    },
    sendcloud_fallback: {
      from: 'KnewOne <welcome@service.knewone.com>',
      delivery_settings: {
        address: 'smtpcloud.sohu.com',
        port: 25,
        user_name: 'postmaster@knewone-info.sendcloud.org',
        password: 'ckfsuXRzZugsoHib',
        authentication: 'login',
        domain: 'sendcloud.org'
      }
    }
  }

  EXCEPTIONAL = {
    'gmail.com' => :mailgun,
    'ruby-china.org' => :mailgun,
    'live.com' => :mailgun
  }
end

