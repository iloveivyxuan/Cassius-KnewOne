class ThingStatsWorker
  include Sidekiq::Worker

  def perform(thing_id)
    thing = Thing.find(thing_id)

    thing.set reviews_count: thing.reviews.count
  end
end
