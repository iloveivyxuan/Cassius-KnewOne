class ThingStatsWorker
  include Sidekiq::Worker

  def perform(thing_id)
    thing = Thing.find(thing_id)

    thing.inc :reviews_count, thing.reviews.count
  end
end
