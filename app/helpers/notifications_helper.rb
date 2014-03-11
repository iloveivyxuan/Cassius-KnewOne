# -*- coding: utf-8 -*-
module NotificationsHelper
  def senders(message)
    links = message.senders.map do |sender|
      link_to sender.name, sender
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
        content += "产品 "
        content += link_to post.title, thing_path(post)
      when Review then
        content += "评测 "
        content += link_to post.title, thing_review_path(post.thing, post)
      when Topic then
        content += "帖子 "
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

  def render_comment(notification)
    html = ''
    html += senders(notification)
    if notification.context.nil?
      html += ' 回复了已经被删除的资源'
    elsif notification.context.author == current_user
      html += " 回复了我发布的#{notification_post(notification.context)}"
    else
      html += " 在对#{notification_post(notification.context)} 的回复中提到了我"
    end
    html.html_safe
  end

  def render_new_review(notification)
    return '' unless notification.context
    html = ''

    html += senders(notification)
    if notification.context.author == current_user
      html += ' 为我分享的产品发表了评测 '
    else
      html += ' 为我喜欢的产品发表了评测 '
    end
    html += link_to notification.context.title, thing_review_path(notification.context.thing, notification.context)

    html.html_safe
  end

  def render_new_stock(notification)
    html = ''

    html += link_to notification.context.title, notification.context
    html += ' 有现货'

    html.html_safe
  end
end
