# -*- coding: utf-8 -*-
class DialogPresenter < ApplicationPresenter
  presents :dialog

  def sender_avatar
    present(dialog.sender).link_to_with_avatar(:small)
  end

  def sender_name
    sender = present(dialog.sender).link_to_with_name
    newest_message.is_in ? sender : raw("我发送给 #{sender}")
  end

  def newest_message_content
    simple_format newest_message.content
  end

  def newest_message_time
    time_ago_tag newest_message.created_at
  end

  def messages_count
    dialog.private_messages.count
  end

  def newest_message
    @newest_message ||= dialog.private_messages.first
  end

  def new_messages_count
    @new_messages_count ||= dialog.private_messages.where(is_new: true, is_in: true).count
    nil if @new_messages_count == 0
  end
end
