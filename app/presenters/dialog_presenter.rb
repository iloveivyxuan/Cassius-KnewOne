class DialogPresenter < ApplicationPresenter
  presents :dialog

  def sender_avatar
    present(dialog.sender).link_to_with_avatar(:small)
  end

  def sender_name
    present(dialog.sender).link_to_with_name
  end

  def newest_message_content
    simple_format newest_message.content
  end

  def newest_message_time
    time_ago_tag newest_message.created_at
  end

  def newest_message
    dialog.private_messages.first
  end

  def messages_count
    dialog.private_messages.count
  end
end
