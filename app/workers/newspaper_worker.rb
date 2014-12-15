class NewspaperWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :newspaper, :backtrace => true

  def perform(user_id, date = Date.today)
    UserMailer.newspaper(user_id, date).deliver
  end
end
