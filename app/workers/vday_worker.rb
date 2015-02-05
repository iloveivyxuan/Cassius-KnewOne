class VdayWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :edm, :backtrace => true, :retry => false

  def perform(email, name)
    UserMailer.vday(email, name).deliver
  end
end
