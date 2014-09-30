class AnnouncementWorker
  include Sidekiq::Worker
  sidekiq_options :queue => :edm, :backtrace => true, :retry => false

  def perform(email, name)
    UserMailer.announcement(email, name).deliver
  end
end
