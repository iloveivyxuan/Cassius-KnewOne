class ReviewNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications

  def perform(review_id, type, options = {})
    r = Review.find(review_id)
    t = r.thing
    user_ids = (t.fancier_ids + t.owner_ids + [t.author.id]).uniq - [r.author.id]

    User.where(:id.in => user_ids).each do |u|
      u.notify type, {context: r}.merge(options)
    end
  end
end
