module FeedsHelper
  def render_feeds(activities)
    present_feeds(activities).reduce("") do |html, fp|
      html.concat fp.render_to_html
    end.html_safe
  end

  def present_feeds(activities)
    feeds = activities.map { |a| present(a, FeedPresenter) }
    # merge_feeds feeds
  end

  def merge_feeds(feeds)
    feeds = feeds.group_by(&:identifier).map do |g|
      g.last.reduce(nil) do |f_merged, f|
        f_merged ||= f
      end
    end
    logger.debug feeds
    feeds
  end

end
