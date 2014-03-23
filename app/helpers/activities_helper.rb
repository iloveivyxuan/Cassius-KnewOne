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
    love_review: 'fa-thumbs-up'
  }

  TYPE_TEMPLATE_MAPPER = {
      new_thing: :thing,
      own_thing: :thing,
      fancy_thing: :thing,
      new_review: :review,
      love_review: :review
  }

  def feed_type_icon_class(activity)
    TYPE_ICON_CLASS_MAPPER[activity.type]
  end

  def render_feed(activity)
    render "activities/feeds/#{TYPE_TEMPLATE_MAPPER[activity.type]}", activity: activity
  end

  def render_feeds(activities)
    activities.map {|a| render_feed(a)}.join.html_safe
  end
end
