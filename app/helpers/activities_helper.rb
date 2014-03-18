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
    html += "赞了评测#{link_to activity.reference.title, thing_review_path(thing, activity.reference), target: target}"

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

  TYPE_ICON_CLASS_MAPPER = {
    new_thing: 'fa-magic',
    own_thing: 'fa-check',
    fancy_thing: 'fa-heart',
    new_review: 'fa-pencil',
    love_review: 'fa-thumbs-up'
  }

  TYPE_TEMPLATE_MAPPER = {
      new_thing: :thing,
      own_thing: :thing,
      fancy_thing: :thing,
      new_review: :review,
      love_review: :review
  }

  def render_activity(activity)
    render "activities/#{TYPE_TEMPLATE_MAPPER[activity.type]}", activity: activity
  end

  def render_activities(activities)
    activities.map {|a| render_activity(a)}.join.html_safe
  end

  def activity_type_icon_class(activity)
    TYPE_ICON_CLASS_MAPPER[activity.type]
  end
end
