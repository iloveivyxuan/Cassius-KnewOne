json.partial! 'api/v1/groups/group', group: @group

json.fancies @group.fancies do |t|
  json.partial! 'api/v1/things/thing', thing: t
end
json.recent_topics do
  json.array! @topics, partial: 'api/v1/topics/topic', as: :topic
end
