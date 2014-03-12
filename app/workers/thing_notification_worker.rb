class ThingNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications

  def perform(thing_id, target, type, options = {})
    t = Thing.find(thing_id)
    t.send(target).each do |u|
      u.notify type, {context: t}.merge(options)
    end
  end
end
