class EmailWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :edm, :backtrace => true#, :retry => false

  def perform(email, name)
    UserMailer.weloop(email, name).deliver
  end
end
