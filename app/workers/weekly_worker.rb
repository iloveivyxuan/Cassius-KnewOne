class WeeklyWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :weekly, :backtrace => true

  def perform(weekly_id, user_id)
    user = User.find user_id
    weekly = Weekly.find weekly_id

    UserMailer.weekly(weekly, user).deliver_now
  end
end
