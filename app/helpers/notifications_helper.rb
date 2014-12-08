module NotificationsHelper
  NOTIFICATION_TAB_ICONS_MAPPING = {
      thing: 'fa-pencil',
      reply: 'fa-comment-o',
      friend: 'fa-eye',
      fancy: 'fa-heart-o'
  }

  def senders(message, target = '_self')
    links = message.senders.map do |sender|
      link_to sender.name, sender, target: target
    end.take(5).join('，')

    if message.senders.count > 5
      links += "等#{message.senders.count}人"
    end
    raw "#{links} "
  end

  def notification_post(post, target = '_blank', anchor = nil)
    content = ""
    case post.class
    when Article then
      if entry = post.entry
        content += "文章 "
        content += link_to post.title, entry_path(entry, anchor: anchor), target: target
      else
        content += ' 失效的资源'
      end
    when Special then
      if entry = post.entry
        content += "专题 "
        content += link_to post.title, entry_path(entry, anchor: anchor), target: target
      else
        content += ' 失效的资源'
      end
    when Thing then
      content += "产品 "
      content += link_to post.title, thing_path(post, anchor: anchor), target: target
    when Review then
      if post.thing
        content += "评测 "
        content += link_to post.title, thing_review_path(post.thing, post, anchor: anchor), target: target
      else
        content += ' 失效的资源'
      end
    when Feeling then
      if post.thing
        content += link_to ' 短评', thing_feeling_path(post.thing, post, anchor: anchor), target: target
      else
        content += ' 失效的资源'
      end
    when Topic then
      content += "帖子 "
      content += link_to post.title, group_topic_path(post.group, post, anchor: anchor), target: target
    when Story then
      content += "动态 "
      content += link_to post.title, thing_story_path(post.thing, post, anchor: anchor), target: target
    when ThingList then
      list = post
      content += "列表 "
      content += link_to list.name, thing_list_path(list, anchor: anchor), target: target
    else
      content += ' 失效的资源'
    end

    raw content
  end

  def unread_notifications_count
    @_unread_count ||= current_user.unread_notifications_count
    @_unread_count > 0 ? @_unread_count : ''
  end

  def unread_notifications_text
    @_unread_count ||= current_user.unread_notifications_count
    @_unread_count > 0 ? "#{@_unread_count} 条" : '没有'
  end

  def render_notification(notification)
    return if notification.orphan?
    render "notifications/#{notification.type}", notification: notification
  end

  def notification_tab_icon(key)
    NOTIFICATION_TAB_ICONS_MAPPING[key]
  end
end
