# -*- coding: utf-8 -*-
module NotificationsHelper
  def senders(message, target = '_self')
    links = message.senders.map do |sender|
      link_to sender.name, sender, target: target
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
        content += link_to post.title, thing_path(post), target: target
      when Review then
        content += "评测"
        content += link_to post.title, thing_review_path(post.thing, post), target: target
      when Topic then
        content += "帖子"
        content += link_to post.title, group_topic_path(post.group, post), target: target
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

  def render_comment_notification(notification, target = '_self')
    html = ''
    html += senders(notification)
    if notification.context.nil?
      html += '回复了已经被删除的资源'
    elsif notification.context.author == current_user
      html += "回复了我发布的#{notification_post(notification.context, target)}"
    else
      html += "在对#{notification_post(notification.context, target)}的回复中提到了我"
    end
    html.html_safe
  end

  def render_new_review_notification(notification, target = '_self')
    return '' unless notification.context
    html = ''

    html += senders(notification)
    if notification.context.author == current_user
      html += '为我分享的产品发表了评测'
    else
      html += '为我喜欢的产品发表了评测'
    end
    html += link_to notification.context.title, thing_review_path(notification.context.thing, notification.context), target: target

    html.html_safe
  end

  def render_stock_notification(notification, target = '_self')
    html = ''

    html += link_to notification.context.title, notification.context, target: target
    html += '有现货'

    html.html_safe
  end
end
