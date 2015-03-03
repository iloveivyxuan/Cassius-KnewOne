class AdoptWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :edm, :backtrace => true, :retry => false

  def perform(email, name)
    UserMailer.adopt(email, name).deliver_now
  end
end
