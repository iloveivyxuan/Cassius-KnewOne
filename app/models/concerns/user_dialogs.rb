module UserDialogs
  extend ActiveSupport::Concern

  included do
    has_many :dialogs
  end

  def send_private_message_to(receiver, content)
    return nil unless receiver and content

    dialog = Dialog.find_or_create_by sender: self, user: receiver
    dialog.private_messages << PrivateMessage.new(content: content, is_new: true, is_in: true)

    dialog = Dialog.find_or_create_by sender: receiver, user: self
    message = PrivateMessage.new(content: content)
    dialog.private_messages << message

    message
  end

  def unread_private_messages_count
    dialogs.map(&:unread_count).reduce(:+)
  end
end
