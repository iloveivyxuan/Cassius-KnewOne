class FeelingNotificationWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :notifications

  def perform(feeling_id, type, options = {})
    r = Feeling.where(id: feeling_id).first
    t = r.thing
    user_ids = (t.fancier_ids + t.owner_ids + [t.author.id]).uniq - [r.author.id]

    User.where(:id.in => user_ids).each do |u|
      u.notify type, {context: r}.merge(options)
    end
  end
end
