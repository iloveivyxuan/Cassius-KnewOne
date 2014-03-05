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

  def newest_message
    @newest_message ||= dialog.private_messages.first
  end

  def newest_message_content
    simple_format newest_message.content
  end

  def newest_message_time
    time_ago_tag newest_message.created_at
  end

  def messages_count
    link_to "#{dialog.private_messages.count}条对话", dialog
  end

  def unread_count
    if dialog.unread_count > 0
      link_to dialog.unread_count, dialog
    else
      nil
    end
  end

  def reply
    link_to_with_icon '回复', 'fa fa-reply', "#"
  end

  def destroy
    link_to_with_icon '删除', 'fa fa-trash-o', "#", title: "删除对话",
    method: :delete, data: {confirm: "您确定要删除此对话吗?"}
  end
end
