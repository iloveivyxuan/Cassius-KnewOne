json.id notification.id.to_s
json.read notification.read
json.type notification.type
json.created_at notification.created_at

json.senders notification.senders do |u|
  json.partial! 'api/v1/users/user', user: u
end
