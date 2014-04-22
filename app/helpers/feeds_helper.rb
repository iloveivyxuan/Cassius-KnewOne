module FeedsHelper
  def render_feed_action(feed)
    render "feeds/actions/#{feed.type.to_s}", feed: feed
  end

  def render_feed(feed)
    tmpl = feed.type.to_s.split('_').last
    render "feeds/#{tmpl}", feed: feed
  end

  def merge_feeds(feeds)
    feeds
  end

  def sort_feeds(feeds)
    feeds = merge_feeds(feeds)
  end

  def render_feeds(feeds)
    sort_feeds(feeds).reduce("") do |html, feed|
      html.concat render_feed(feed)
    end.html_safe
  end
end
