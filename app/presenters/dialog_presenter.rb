# -*- coding: utf-8 -*-
class DialogPresenter < ApplicationPresenter
  presents :dialog

  def sender_avatar
    present(dialog.sender).link_to_with_avatar(:tiny)
  end

  def sender_name
    sender = present(dialog.sender).link_to_with_name
    dialog.newest_message.is_in ? sender : raw("我发送给 #{sender}")
  end

  def newest_message_content
    present(dialog.newest_message).content
  end

  def updated_at
    time_ago_tag dialog.updated_at
  end

  def messages_count
    link_to dialog.private_messages.count, dialog, title: "查看会话",
    class: (dialog.unread ? "unread" : nil)
  end

  def reply
    link_to_with_icon '回复', 'fa fa-reply', dialog
  end

  def destroy
    link_to_with_icon '删除', 'fa fa-trash-o', dialog, title: "删除对话",
    method: :delete, remote: true, data: {confirm: "您确定要删除此对话吗?"}
  end
end
