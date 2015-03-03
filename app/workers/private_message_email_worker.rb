class PrivateMessageEmailWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :mails, :backtrace => true

  def perform(dialog_id)
    dialog = Dialog.find(dialog_id)
    if dialog.unread_count > 0 && dialog.user.email.present?
      UserMailer.private_message(dialog).deliver_now
    end
  end
end
