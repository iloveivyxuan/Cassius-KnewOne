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
    @display = (tmpl == "thing" ? :third : :row)
    {third: "col-sm-4", row: "col-sm-12"}[@display]
  end

  def render_to_html
    render "feeds/#{tmpl}", fp: self
  end

  def render_action
    users_html = render "feeds/actions/users", user: activity.user
    action_html = render "feeds/actions/#{activity.type.to_s}"
    users_html.concat action_html
  end
end
