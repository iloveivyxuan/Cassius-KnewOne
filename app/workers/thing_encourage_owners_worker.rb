class ThingEncourageOwnersWorker
  include Sidekiq::Worker
  sidekiq_options queue: :mails, retry: false

  def perform(thing_id)
    t = Thing.find(thing_id)
    t.owners.each do |u|
      ThingMailer.create_encourage_owner(t, u).deliver rescue Exception
    end
  end
end
