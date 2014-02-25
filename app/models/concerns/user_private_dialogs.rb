module UserPrivateDialogs
  extend ActiveSupport::Concern

  included do
    has_many :private_dialogs
  end

  def send_private_message_to(receiver, content)
    dialog = PrivateDialog.find_or_create_by sender: self, user: receiver
    dialog.private_messages << PrivateMessage.new(content: content, is_new: true, is_in: true)

    dialog = PrivateDialog.find_or_create_by sender: receiver, user: self
    dialog.private_messages << PrivateMessage.new(content: content)
  end
end
