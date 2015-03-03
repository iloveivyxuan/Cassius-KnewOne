class ThingNotificationWorker
  include Sidekiq::Worker
  sidekiq_options queue: :notifications, retry: false

  def perform(thing_id, target, type, options = {})
    t = Thing.find(thing_id)
    t.send(target).each do |u|
      u.notify type, {context: t}.merge(options)
      UserMailer.stock(u, t).deliver_now rescue Exception
    end
  end
end
