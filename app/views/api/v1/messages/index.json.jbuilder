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
        when Review then
          json.type_text('评测')
          json.url url_wrapper(msg.post.thing, msg.post)
        when Topic then
          json.type_text('帖子')
          json.url url_wrapper(msg.post.group, msg.post)
      end
      json.title msg.post.title
    end
  end
  json.is_read msg.read?
  json.created_at msg.created_at
end
