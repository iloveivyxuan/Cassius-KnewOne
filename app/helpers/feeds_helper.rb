module FeedsHelper
  def render_feeds(activities)
    present_feeds(activities).reduce("") do |html, fp|
      html.concat fp.render_to_html
    end.html_safe
  end

  def present_feeds(activities)
    feeds = activities.map { |a| present(a, FeedPresenter) }
    uniq_feeds feeds
  end

  def uniq_feeds(feeds)
    feeds.group_by(&:identifier).map do |group|
      group.last.reduce(nil) do |f_merged, f|
        f_merged ||= f
        f_merged.add_user f.activity.user
        f_merged
      end
    end
  end
end
