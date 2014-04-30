class EmailWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :edm, :backtrace => true

  def perform(email, name)
    UserMailer.mail2(email, name).deliver
  end
end
