json.array! @messages do |msg|
  json.senders msg.senders do |u|
    json.partial! 'api/v1/users/user', user: u
  end
  if msg.context
    json.source do
      json.type msg.post.class.to_s.underscore
      case msg.context.class
        when Thing then
          json.type_text('产品')
          json.url url_wrapper(msg.context)
          json.html_url thing_url(msg.context)
        when Review then
          json.type_text('评测')
          json.url url_wrapper(msg.context.thing, msg.context)
          json.html_url thing_review_url(msg.context.thing, msg.context)
        when Topic then
          json.type_text('帖子')
          json.url url_wrapper(msg.context.group, msg.context)
          json.html_url group_topic_url(msg.context.group, msg.context)
        else
          json.type_text('失效的资源')
      end
      json.title msg.context.title
    end
  end
  json.is_read msg.read?
  json.created_at msg.created_at
end
