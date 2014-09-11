class FeedPresenter < ApplicationPresenter
  presents :activity
  delegate :reference_union, :reference, :source, to: :activity

  def tmpl
    @tmpl ||= activity.type.to_s.split('_').last
  end

  def display=(style)
    if [:third, :row].include? style
      @display = style
    end
  end

  def style
    ""
  end

  def render_to_html
    render "feeds/#{tmpl}", fp: self
  end

  def action
    raw case activity.type
        when :new_thing   then '发布'
        when :own_thing   then '拥有'
        when :fancy_thing then '喜欢'
        when :new_review  then '发表'
        when :love_review then '赞'
        when :new_feeling then '发表了' + link_to('短评', [activity.reference.thing, activity.reference])
        when :add_to_list then '加入' + link_to(activity.source.name, activity.source) + '列表'
        when :fancy_list  then '喜欢该列表'
        end
  end

  def render_action
    users_html = render "feeds/actions/users", user: activity.user
    action_html = render "feeds/actions/#{activity.type.to_s}"
    users_html.concat action_html
  end
end
