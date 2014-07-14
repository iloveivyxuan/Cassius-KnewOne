class NewspaperWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :newspaper, :backtrace => true, retry: false

  def perform(user_id, date_str)
    UserMailer.newspaper(user_id, Date.parse(date_str)).deliver
  end
end
