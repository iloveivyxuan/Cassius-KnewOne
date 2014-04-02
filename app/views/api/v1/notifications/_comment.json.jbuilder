if context = notification.context
  json.id notification.id.to_s
  json.read notification.read
  json.type notification.type
  json.created_at notification.created_at

  json.senders notification.senders do |u|
    json.partial! 'api/v1/users/user', user: u
  end

  case context.class
    when Thing
      json.context_type 'thing'
      json.thing do
        json.partial! 'api/v1/things/thing', thing: context
      end
    when Review
      json.context_type 'review'
      json.review do
        json.partial! 'api/v1/reviews/review', review: context
      end
    when Topic
      json.context_type 'topic'
      json.topic do
        json.partial! 'api/v1/topics/topic', topic: context
      end
  end
end

