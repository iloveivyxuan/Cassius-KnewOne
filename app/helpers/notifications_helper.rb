# -*- coding: utf-8 -*-
module NotificationsHelper
  def render_notification(n)
    render "notifications/#{n.type}", notification: n
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

  def notification_post(post)
    content = ""
    case post.class
      when Thing then
        content += "产品"
        content += link_to present(post).full_title, thing_path(post)
      when Review then
        content += "评测"
        content += link_to post.title, thing_review_path(post.thing, post)
      when Topic then
        content += "帖子"
        content += link_to post.title, group_topic_path(post.group, post)
      else
        content += '失效的资源'
    end

    raw content
  end

  def unread_notifications_count
    count = current_user.notifications.unread.count
    (count > 0) ? count : ''
  end

  def unread_notifications_text
    count = unread_notifications_count
    if count.blank?
      '没有'
    else
      "#{count} 条"
    end
  end
end
