class NewspaperWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :newspaper, :backtrace => true

  def perform(user_id, date_str = Date.today.to_s)
    UserMailer.newspaper(user_id, date_str).deliver
  end
end
