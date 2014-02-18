class DeviseMailer < Devise::Mailer
  layout 'mailer'
  default from: 'welcome@knewone.com',
          content_type: 'text/html',
          reply_to: 'welcome@knewone.com'

  def confirmation_instructions(record_id, token, opts={})
    record = User.find(record_id)
    @token = token
    devise_mail(record, :confirmation_instructions, opts)
  end

  def reset_password_instructions(record_id, token, opts={})
    record = User.find(record_id)
    @token = token
    devise_mail(record, :reset_password_instructions, opts)
  end

  def unlock_instructions(record_id, token, opts={})
    record = User.find(record_id)
    @token = token
    devise_mail(record, :unlock_instructions, opts)
  end
end
