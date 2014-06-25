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
    case activity.type
    when :new_thing    then '发布'
    when :own_thing    then '拥有'
    when :fancy_thing  then '喜欢'
    when :new_review   then '发布评测'
    when :love_review  then '赞评测'
    when :new_feeling  then '发布短评'
    when :love_feeling then '赞短评'
    when :new_topic    then '发布话题'
    end
  end

  def render_action
    users_html = render "feeds/actions/users", user: activity.user
    action_html = render "feeds/actions/#{activity.type.to_s}"
    users_html.concat action_html
  end
end
