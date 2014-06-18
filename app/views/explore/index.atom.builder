atom_feed do |feed|
  feed.title("KnewOne Explore")
  feed.updated(Entry.published.first.created_at)

  @entries.each do |e|
    post = Post.find(e.post_id)
    url = url_for(:action => 'show', :controller => 'entries', :id => e.id)
    feed.entry(post, :url => url) do |entry| ##
      entry.title(post.title)
      entry.content(post.content, type: 'html')
      entry.author do |author|
        author.name(post.author.name)
      end
    end
  end
end
