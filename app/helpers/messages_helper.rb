# -*- coding: utf-8 -*-
module MessagesHelper
  def unread_messages_count
    count = current_user.messages.unread.count
    (count > 0) ? count : ''
  end

  def unread_messages_text
    count = unread_messages_count
    if count.blank?
      '没有'
    else
      "#{count} 条"
    end
  end

  def message_type(message)
    message.class.to_s.underscore
  end

  def message_post(post)
    content = ""
    if post.class == Thing
      content += "产品"
      content += link_to present(post).full_title, thing_path(post)
    elsif post.class == Review
      if post.thing.nil?
        content += '失效产品的评测'
      else
        content += "评测"
        content += link_to post.title, thing_review_path(post.thing, post)
      end
    elsif post.class == Topic
      if post.group.nil?
        content += "失效小组的帖子"
      else
        content += "帖子"
        content += link_to post.title, group_topic_path(post.group, post)
      end
    end
    raw content
  end

  def senders(message)
    links = message.senders.map do |sender|
      link_to sender.name, sender, class: "btn btn-link"
    end.take(5).join('，')

    if message.senders.count > 5
      links += "等#{message.senders.count}人"
    end
    raw links
  end
end
