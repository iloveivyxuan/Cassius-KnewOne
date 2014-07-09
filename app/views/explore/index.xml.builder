xml.rss :version => "2.0" do
  xml.channel do
    xml.title "KnewOne Explore"
    xml.description "KnewOne, 探索分享新奇酷"
    xml.link explore_url(format: "xml")

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

      xml.item do
        xml.title post.title
        xml.description post.content
        xml.author { |author| author.name(post.author.name) }
        xml.pubDate post.created_at.to_s(:rfc822)
        xml.cover e.cover.url(:normal)
        link = url_for(:action => 'show', :controller => 'entries', :id => e.id)
        xml.link "#{link}?source=xml"
      end

    end
  end
end
