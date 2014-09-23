xml.rss :version => "2.0" do
  xml.channel do
    xml.title "KnewOne 评测"
    xml.description "KnewOne, 探索分享新奇酷"
    xml.link maps_reviews_url(format: "xml")

    @reviews.each do |review|
      xml.item do
        xml.cover review.cover(:normal)
        xml.title review.thing.title
        xml.author review.author.name
        present review do |rp|
          xml.description "<h1>#{review.title}</h1>" + rp.content_with_original_photos, :type => 'html'
        end
        xml.pubDate review.created_at.to_s(:rfc822)
        link = thing_review_url(review.thing.id, review.id)
        xml.link "#{link}?source=xml"
      end

    end
  end
end
