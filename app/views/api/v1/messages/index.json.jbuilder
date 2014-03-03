json.array! @messages do |msg|
  json.senders msg.senders do |u|
    json.partial! 'api/v1/users/user', user: u
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
          json.type_text('评测')
          json.url url_wrapper(msg.post.thing, msg.post)
          json.html_url thing_review_url(msg.post.thing, msg.post)
        when Topic then
          json.type_text('帖子')
          json.url url_wrapper(msg.post.group, msg.post)
          json.html_url group_topic_url(msg.post.group, msg.post)
        else
          json.type_text('失效的资源')
      end
      json.title msg.post.title
    end
  end
  json.is_read msg.read?
  json.created_at msg.created_at
end
