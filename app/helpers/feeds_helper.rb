module FeedsHelper

  def render_feeds(activities)
    present_feeds(activities).reduce("") do |html, fp|
      html.concat fp.render_to_html
    end.html_safe
  end

  def present_feeds(activities)
    feeds = activities
      .uniq(&:reference_union)
      .select(&:reference)
      .map { |a| present(a, FeedPresenter) }
    feeds
  end

end
