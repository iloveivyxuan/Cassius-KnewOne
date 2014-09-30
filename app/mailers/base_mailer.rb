class BaseMailer < ActionMailer::Base
  abstract!
  layout 'mailer'
  default content_type: 'text/html',
          reply_to: 'help@knewone.com'
  before_action :set_logo

  protected

  def set_logo
    attachments.inline['logo.png'] = File.read(Rails.root.join("app/assets/images/logos/#{rand(21)+1}.png"))
    attachments.inline['ko_wechat_qr.png'] = File.read(Rails.root.join('app/assets/images/mails/ko_wechat_qr.png'))
  end
end
