module ThingStatsable
  extend ActiveSupport::Concern

  included do
    after_save :refresh_thing_stats
  end

  def refresh_thing_stats
    thing.refresh_stats!
  end
end
