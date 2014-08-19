class EmailWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :edm, :backtrace => true, :retry => false

  def perform(email, name)
    UserMailer.adopt(email, name).deliver
  end
end
