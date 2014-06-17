class FeedPresenter < ApplicationPresenter
  presents :activity
  delegate :reference_union, :reference, :source, to: :activity

  TAGS = ["col-sm-6", "col-sm-6", "col-sm-4", "col-sm-4", "col-sm-4"]

  def style_tags
    @@tags.pop
  end

  def tmpl
    @tmpl ||= activity.type.to_s.split('_').last
  end

  def display=(style)
    if [:half, :row].include? style
      @display = style
    end
  end

  def style
    @@tags ||= TAGS.clone
    @@tags = TAGS.clone if @@tags.empty?
    tmpl == "thing" ? style_tags : "col-sm-12"
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
