if context = notification.context
  json.id notification.id.to_s
  json.read notification.read
  json.type notification.type
  json.created_at notification.created_at

  json.thing do
    json.partial! 'api/v1/things/thing', thing: context
  end
end
