# -*- coding: utf-8 -*-
module ActivitiesHelper

  def render_activity(activity)
    return unless activity.reference

    tmpl = if activity.type == :comment
             obj_to_s(activity.reference) + "_comment"
           else
             activity.type
           end

    render "activities/#{tmpl}", activity: activity
  end

  TYPE_ICON_CLASS_MAPPER = {
    new_thing: 'fa-magic',
    own_thing: 'fa-check',
    fancy_thing: 'fa-heart',
    new_review: 'fa-pencil',
    love_review: 'fa-plus',
    new_topic: 'fa-pencil',
    love_topic: 'fa-plus'
  }

  TYPE_TEMPLATE_MAPPER = {
    new_thing: :thing,
    own_thing: :thing,
    fancy_thing: :thing,
    new_review: :review,
    love_review: :review,
    new_topic: :topic,
    love_topic: :topic
  }

  TYPE_TEXT_MAPPER = {
    new_thing: '分享了产品',
    own_thing: '拥有了产品',
    fancy_thing: '喜欢了产品',
    new_review: '发表了评测',
    love_review: '赞了评测',
    new_topic: '发表了话题',
    love_topic: '赞了话题'
  }

  def feed_type_icon_class(activity)
    TYPE_ICON_CLASS_MAPPER[activity.type]
  end

  def feed_type_text(activity)
    content_tag :span, TYPE_TEXT_MAPPER[activity.type], class: 'meta feed_text'
  end

  def render_feed(activity)
    render "activities/feeds/#{TYPE_TEMPLATE_MAPPER[activity.type]}", activity: activity
  end

  def render_feeds(activities)
    activities.map {|a| render_feed(a)}.join.html_safe
  end

end
