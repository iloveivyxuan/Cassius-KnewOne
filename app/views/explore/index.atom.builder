atom_feed do |feed|
  feed.title("KnewOne Explore")
  feed.updated(Entry.published.first.created_at)

  @entries.each do |e|
    if e.post_id.blank?
      post = Post.new(
                      title: e.title,
                      content: auto_link(e.external_link),
                      author: { name: "KnewOne" },
                      created_at: e.created_at)
    else
      post = Post.find(e.post_id)
    end
    url = entry_url(e.id)
    feed.entry(post, :url => "#{url}?source=atom") do |entry|
      entry.title(post.title)
      entry.content(post.content, type: 'html')
      entry.cover e.cover.url(:normal)
      xml.author { |author| author.name(post.author.name) }
      entry.pubDate post.created_at.to_s(:rfc822)
      entry.link url
    end
  end
end
