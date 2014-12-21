class WeeklyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :weekly, :backtrace => true

  def perform(weekly_id, user_id)
    UserMailer.weekly(weekly_id, user_id).deliver
  end
end
