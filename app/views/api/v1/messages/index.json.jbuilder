json.array! @messages do |msg|
  json.senders msg.senders do |u|
    json.id u.id.to_s
    json.url url_wrapper(u)
    json.avatar_url u.avatar.url
    json.name u.name
  end
  if msg.post
    json.source do
      json.type msg.post.class.to_s.underscore
      case msg.post.class
        when Thing then
          json.type_text('产品')
          json.url url_wrapper(msg.post)
          json.html_url thing_url(msg.post)
        when Review then
          if msg.post.thing.nil?
            json.type_text('失效产品的评测')
          else
            json.type_text('评测')
            json.url url_wrapper(msg.post.thing, msg.post)
            json.html_url thing_review_url(msg.post.thing, msg.post)
          end

        when Topic then
          if msg.post.group.nil?
            json.type_text('失效小组的帖子')
          else
            json.type_text('帖子')
            json.url url_wrapper(msg.post.group, msg.post)
            json.html_url group_topic_url(msg.post.thing, msg.post)
          end
      end
      json.title msg.post.title
    end
  end
  json.is_read msg.read?
  json.created_at msg.created_at
end
