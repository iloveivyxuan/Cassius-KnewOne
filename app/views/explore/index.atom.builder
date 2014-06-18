atom_feed do |feed|
  feed.title("KnewOne Explore")
  feed.updated(Entry.published.first.created_at)

  @entries.each do |e|
    if e.post_id.blank?
      post = Post.new(title: e.title, content: auto_link(e.external_link), author: { name: "KnewOne" })
    else
      post = Post.find(e.post_id)
    end
    url = url_for(:action => 'show', :controller => 'entries', :id => e.id)
    feed.entry(post, :url => url) do |entry| ##
      entry.title(post.title)
      entry.content(post.content, type: 'html')
      entry.link href: e.cover.url(:large), rel:"enclosure", type:"image/jpeg"
      entry.author do |author|
        author.name(post.author.name)
      end
    end
  end
end
