module ActivitiesHelper
  def render_activity(activity, rich = false)
    return unless activity.reference

    tmpl = if activity.type == :comment
             obj_to_s(activity.reference) + "_comment"
           else
             activity.type
           end

    render "activities/#{tmpl}", activity: activity, rich: rich
  end

  def action_of_activity(activity)
    raw case activity.type
        when :new_thing    then '发布'
        when :fancy_thing  then '喜欢'
        when :desire_thing then '想要'
        when :own_thing    then '拥有'
        when :new_review   then '发表'
        when :love_review  then '赞'
        when :new_feeling  then '发表了' + link_to('短评', [activity.related_thing, activity.reference])
        when :add_to_list  then '加入' + link_to(activity.source.name, activity.source) + '列表'
        when :fancy_list   then '喜欢该列表'
        end
  end
end
