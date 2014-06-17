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
    sort_feeds feeds
  end

  def sort_feeds(feeds)
    thing_feeds, post_feeds = [], []
    feeds.each { |f| (f.tmpl == "thing" ? thing_feeds : post_feeds) << f }
    if thing_feeds.length % 2 > 0
      thing_feeds.last.display = :row
    end
    arrange_feeds thing_feeds, post_feeds
  end

  def arrange_feeds(thing_feeds, post_feeds, scratch_thing = true)
    return [] if thing_feeds.blank? and post_feeds.blank?
    scratched = scratch_thing ? thing_feeds.shift(5) : post_feeds.shift(2)
    scratched + arrange_feeds(thing_feeds, post_feeds, !scratch_thing)
  end
end
