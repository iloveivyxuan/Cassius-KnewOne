# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "http://knewone.com"

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  Thing.published.each do |t|
    add thing_path(t), :lastmod => t.updated_at

    t.reviews.each do |r|
      add thing_review_path(t, r), :lastmod => t.updated_at
    end

    t.stories.each do |s|
      add thing_story_path(t, s), :lastmod => t.updated_at
    end
  end

  Group.public.each do |g|
    add group_path(g)

    g.topics.each do |t|
      add group_topic_path(g, t), :lastmod => t.updated_at
    end
  end

  Category.where(:things_count.gt => 0).each do |c|
    add "/things/category/#{c.slug}"
  end

  Entry.published.each do |e|
    if e.post
      add entry_path(e)
    end
  end
end
