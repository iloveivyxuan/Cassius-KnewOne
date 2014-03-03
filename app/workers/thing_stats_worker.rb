class ThingStatsWorker
  include Sidekiq::Worker

  def perform(thing_id)
    thing = Thing.find(thing_id)

    thing.reviews_count = thing.reviews.count

    thing.save!
  end
end
