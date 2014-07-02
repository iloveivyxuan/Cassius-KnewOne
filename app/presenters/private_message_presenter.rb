class PrivateMessagePresenter < ApplicationPresenter
  presents :private_message

  def sender
    @sender ||= if private_message.is_in?
                  private_message.dialog.sender
                else
                  private_message.dialog.user
                end
  end

  def avatar
    present(sender).link_to_with_avatar(:tiny)
  end

  def sender_name
    present(sender).link_to_with_name
  end

  def content
    simple_format private_message.content
  end

  def created_at
    time_ago_tag private_message.created_at
  end

  def destroy
    link_to_with_icon '删除', 'fa fa-trash-o',
    dialog_private_message_path(private_message.dialog, private_message),
    title: "删除", method: :delete, remote: true, data: {confirm: "您确定要删除此私信吗?"}
  end
end
