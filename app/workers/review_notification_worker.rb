class ReviewNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications

  def perform(thing_id, target, type, options = {})
    r = Review.find(thing_id)
    r.thing.send(target).each do |u|
      u.notify type, {context: r}.merge(options)
    end
  end
end
