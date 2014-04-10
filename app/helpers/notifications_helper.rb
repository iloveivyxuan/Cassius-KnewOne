# -*- coding: utf-8 -*-
module NotificationsHelper
  def senders(message, target = '_self')
    links = message.senders.map do |sender|
      link_to sender.name, user_url(sender), target: target
    end.take(5).join('，')

    if message.senders.count > 5
      links += "等#{message.senders.count}人"
    end
    raw links
  end

  def notification_post(post, target = '_blank')
    content = ""
    case post.class
      when Thing then
        content += "产品"
        content += link_to post.title, thing_url(post), target: target
      when Review then
        content += "评测"
        content += link_to post.title, thing_review_url(post.thing, post), target: target
      when Topic then
        content += "帖子"
        content += link_to post.title, group_topic_url(post.group, post), target: target
      else
        content += '失效的资源'
    end

    raw content
  end

  def unread_notifications_count
    @_unread_count ||= current_user.notifications.unread.count
    @_unread_count > 0 ? @_unread_count : ''
  end

  def unread_notifications_text
    @_unread_count ||= current_user.notifications.unread.count
    @_unread_count > 0 ? "#{@_unread_count} 条" : '没有'
  end

  def render_notification(notification)
    return if notification.orphan?
    render "notifications/#{notification.type}", notification: notification
  end
end
