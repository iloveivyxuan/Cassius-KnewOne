class WeeklyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :weekly, :backtrace => true

  def perform(weekly_id, user_id)
    weekly = Weekly.find(weekly_id)
    user = User.find(user_id)
    thing_ids = weekly.friends_hot_thing_ids_without_global_of(user)

    UserMailer.weekly(weekly_id.to_s, user_id.to_s, thing_ids.map(&:to_s)).deliver_later
  end
end
