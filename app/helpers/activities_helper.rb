# -*- coding: utf-8 -*-
module ActivitiesHelper
  def render_activity(activity)
    return unless activity.reference

    tmpl = if activity.type == :comment
             obj_to_s(activity.reference) + "_comment"
           else
             activity.type
           end

    render("activities/#{tmpl}", activity: activity)
  end
end
