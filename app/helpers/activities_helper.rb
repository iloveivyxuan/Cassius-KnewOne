module ActivitiesHelper
  def render_comment_activity_summary(activity, show_user = true, target = '_self')
    return unless activity.reference

    html = ''
    html += link_to activity.user.name, activity.user, target: target if show_user
    html += '评论了'

    post = activity.reference
    case post.class
      when Thing then
        html += "产品"
        html += link_to post.title, thing_path(post), target: target
      when Review then
        html += "评测"
        html += link_to post.title, thing_review_path(post.thing, post), target: target
      when Topic then
        html += "帖子"
        html += link_to post.title, group_topic_path(post.group, post), target: target
    end

    html.html_safe
  end

  def render_new_thing_activity_summary(activity, show_user = true, target = '_self')
    return unless activity.reference

    html = ''
    html += link_to activity.user.name, activity.user, target: target if show_user
    html += "分享了产品#{link_to activity.reference.title, thing_path(activity.reference), target: target}"

    html.html_safe
  end

  def render_new_review_activity_summary(activity, show_user = true, target = '_self')
    return unless activity.reference
    thing = activity.reference.thing
    return unless thing

    html = ''
    html += link_to activity.user.name, activity.user, target: target if show_user
    html += "为产品#{link_to thing.title, thing_path(thing), target: target}"
    html += "编写了#{link_to '评测', thing_review_path(thing, activity.reference), target: target}"

    html.html_safe
  end

  def render_love_review_activity_summary(activity, show_user = true, target = '_self')
    return unless activity.reference
    thing = activity.reference.thing
    return unless thing

    html = ''
    html += link_to activity.user.name, activity.user, target: target if show_user
    html += "认为评测#{link_to activity.reference.title, thing_review_path(thing, activity.reference), target: target}"
    html += "有用"

    html.html_safe
  end

  def render_fancy_thing_activity_summary(activity, show_user = true, target = '_self')
    return unless activity.reference

    html = ''
    html += link_to activity.user.name, activity.user, target: target if show_user
    html += "喜欢了产品#{link_to activity.reference.title, thing_path(activity.reference), target: target}"

    html.html_safe
  end

  def render_own_thing_activity_summary(activity, show_user = true, target = '_self')
    return unless activity.reference

    html = ''
    html += link_to activity.user.name, activity.user, target: target if show_user
    html += "拥有了产品#{link_to activity.reference.title, thing_path(activity.reference), target: target}"

    html.html_safe
  end

  def render_follow_user_activity_summary(activity, show_user = true, target = '_self')
    return unless activity.reference

    html = ''
    html += link_to activity.user.name, activity.user, target: target if show_user
    html += "关注了用户#{link_to activity.reference.name, user_path(activity.reference), target: target}"

    html.html_safe
  end

  def render_activity_summary(activity, show_user = true, target = '_self')
    send :"render_#{activity.type}_activity_summary", activity, show_user, target
  end
end
